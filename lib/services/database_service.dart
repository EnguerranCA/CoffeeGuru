import 'dart:math' show cos, pi;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service pour gérer la connexion à Supabase
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Initialise la connexion à Supabase
  /// Doit être appelé au démarrage de l'application
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger les variables d'environnement
      await dotenv.load(fileName: '.env');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
          'SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis dans le fichier .env',
        );
      }

      // Initialiser Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      print('✅ Connexion à Supabase établie');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de Supabase: $e');
      rethrow;
    }
  }

  /// Récupère le client Supabase
  SupabaseClient get client {
    if (_client == null || !_isInitialized) {
      throw Exception(
        'DatabaseService non initialisé. Appelez initialize() d\'abord.',
      );
    }
    return _client!;
  }

  /// Vérifie si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Tables de la base de données
  static const String usersTable = 'users';
  static const String cafePlacesTable = 'cafe_places';
  static const String availableCoffeeTypesTable = 'available_coffee_types';
  static const String coffeeLogsTable = 'coffee_logs';

  /// Méthodes utilitaires pour les requêtes courantes

  /// Récupère tous les enregistrements d'une table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur lors de la récupération depuis $table: $e');
      rethrow;
    }
  }

  /// Récupère un enregistrement par ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      final response = await client.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'ID $id depuis $table: $e');
      return null;
    }
  }

  /// Insert un enregistrement
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      print('❌ Erreur lors de l\'insertion dans $table: $e');
      rethrow;
    }
  }

  /// Update un enregistrement
  Future<Map<String, dynamic>?> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await client.from(table).update(data).eq('id', id).select().single();
      return response;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour dans $table: $e');
      rethrow;
    }
  }

  /// Delete un enregistrement
  Future<void> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
    } catch (e) {
      print('❌ Erreur lors de la suppression depuis $table: $e');
      rethrow;
    }
  }

  /// Récupère les CafePlaces proches d'une position
  /// Utilise le théorème de Pythagore pour calculer la distance approximative
  Future<List<Map<String, dynamic>>> getCafePlacesNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Calcul approximatif de la bbox (bounding box)
      // 1 degré de latitude ≈ 111 km
      // 1 degré de longitude ≈ 111 km * cos(latitude)
      final latDelta = radiusKm / 111.0;
      final lonDelta = radiusKm / (111.0 * cos(latitude * pi / 180));

      final response = await client
          .from(cafePlacesTable)
          .select('*, available_coffee_types(*)')
          .gte('latitude', latitude - latDelta)
          .lte('latitude', latitude + latDelta)
          .gte('longitude', longitude - lonDelta)
          .lte('longitude', longitude + lonDelta);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur lors de la récupération des CafePlaces proches: $e');
      rethrow;
    }
  }

  /// Recherche des CafePlaces par nom
  Future<List<Map<String, dynamic>>> searchCafePlaces(String query) async {
    try {
      final response = await client
          .from(cafePlacesTable)
          .select('*, available_coffee_types(*)')
          .ilike('name', '%$query%')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur lors de la recherche de CafePlaces: $e');
      rethrow;
    }
  }

  /// Récupère les logs de café d'un utilisateur
  Future<List<Map<String, dynamic>>> getCoffeeLogsByUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Construire la requête de base
      final query = client
          .from(coffeeLogsTable)
          .select('*, cafe_places(*)')
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      final response = await query;
      var results = List<Map<String, dynamic>>.from(response);

      // Filtrer par date localement (car gte/lte ne sont pas disponibles sur select)
      if (startDate != null) {
        results = results.where((log) {
          final timestamp = DateTime.parse(log['timestamp'] as String);
          return timestamp.isAfter(startDate) || timestamp.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        results = results.where((log) {
          final timestamp = DateTime.parse(log['timestamp'] as String);
          return timestamp.isBefore(endDate) || timestamp.isAtSameMomentAs(endDate);
        }).toList();
      }

      return results;
    } catch (e) {
      print('❌ Erreur lors de la récupération des CoffeeLogs: $e');
      rethrow;
    }
  }
}
