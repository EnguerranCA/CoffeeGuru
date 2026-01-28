import 'package:latlong2/latlong.dart';
import '../models/cafe_place.dart';
import '../models/coffee_log.dart';
import 'database_service.dart';

/// Service pour gérer les cafés
class CafeService {
  // Singleton pattern
  static final CafeService _instance = CafeService._internal();
  factory CafeService() => _instance;
  CafeService._internal();

  final DatabaseService _db = DatabaseService();

  /// Cache local des cafés (optionnel)
  List<Cafe> _cachedCafes = [];

  /// Récupère tous les cafés depuis Supabase
  Future<List<Cafe>> getAllCafes() async {
    try {
      final data = await _db.getAll(DatabaseService.cafePlacesTable);
      _cachedCafes = data.map((json) => Cafe.fromJson(json)).toList();
      return _cachedCafes;
    } catch (e) {
      print('❌ Erreur dans CafeService.getAllCafes: $e');
      return [];
    }
  }

  /// Récupère les cafés à proximité d'une position
  /// [position] Position de référence
  /// [radiusKm] Rayon de recherche en kilomètres
  Future<List<Cafe>> getCafesNearby(LatLng position,
      {double radiusKm = 5.0}) async {
    try {
      final data = await _db.getCafePlacesNearby(
        position.latitude,
        position.longitude,
        radiusKm,
      );

      final cafes = data.map((json) => Cafe.fromJson(json)).toList();

      // Trier par distance
      cafes.sort((a, b) =>
          a.distanceFrom(position).compareTo(b.distanceFrom(position)));

      _cachedCafes = cafes;
      return cafes;
    } catch (e) {
      print('❌ Erreur dans CafeService.getCafesNearby: $e');
      return [];
    }
  }

  /// Filtre les cafés par type d'établissement
  List<Cafe> filterByType(List<CafeType> types) {
    if (types.isEmpty) return _cachedCafes;
    return _cachedCafes.where((cafe) => types.contains(cafe.type)).toList();
  }

  /// Filtre les cafés par types de café disponibles
  List<Cafe> filterByCoffeeType(List<CoffeeType> coffeeTypes) {
    if (coffeeTypes.isEmpty) return _cachedCafes;
    return _cachedCafes
        .where((cafe) => cafe.availableCoffeeTypes
            .any((type) => coffeeTypes.contains(type)))
        .toList();
  }

  /// Recherche un café par nom (via Supabase)
  Future<List<Cafe>> searchByName(String query) async {
    try {
      final data = await _db.searchCafePlaces(query);
      return data.map((json) => Cafe.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur dans CafeService.searchByName: $e');
      return [];
    }
  }

  /// Récupère un café par son ID (via Supabase)
  Future<Cafe?> getCafeById(String id) async {
    try {
      final data = await _db.getById(DatabaseService.cafePlacesTable, id);
      if (data == null) return null;
      return Cafe.fromJson(data);
    } catch (e) {
      print('❌ Erreur dans CafeService.getCafeById: $e');
      return null;
    }
  }

  /// Charge les cafés depuis Supabase (remplace loadDemoCafes)
  Future<void> loadCafesFromAPI(LatLng position) async {
    // Charger les cafés proches de la position
    await getCafesNearby(position, radiusKm: 10);
  }

  /// Ajoute un nouveau café (dans Supabase)
  Future<Cafe?> addCafe(Cafe cafe) async {
    try {
      // Insérer le CafePlace
      final insertedData = await _db.insert(
        DatabaseService.cafePlacesTable,
        cafe.toInsertJson(),
      );

      if (insertedData == null) return null;

      final newCafe = Cafe.fromJson(insertedData);

      // Insérer les types de café disponibles
      for (var coffeeType in cafe.availableCoffeeTypes) {
        await _db.insert(
          DatabaseService.availableCoffeeTypesTable,
          {
            'cafe_place_id': newCafe.id,
            'coffee_type': coffeeType.name,
          },
        );
      }

      // Recharger le café avec les types de café
      final reloadedCafe = await getCafeById(newCafe.id);
      if (reloadedCafe != null) {
        _cachedCafes.add(reloadedCafe);
      }

      return reloadedCafe;
    } catch (e) {
      print('❌ Erreur dans CafeService.addCafe: $e');
      return null;
    }
  }

  /// Supprime un café (de Supabase)
  Future<bool> removeCafe(String id) async {
    try {
      await _db.delete(DatabaseService.cafePlacesTable, id);
      _cachedCafes.removeWhere((cafe) => cafe.id == id);
      return true;
    } catch (e) {
      print('❌ Erreur dans CafeService.removeCafe: $e');
      return false;
    }
  }

  /// Met à jour un café (dans Supabase)
  Future<Cafe?> updateCafe(Cafe updatedCafe) async {
    try {
      final data = await _db.update(
        DatabaseService.cafePlacesTable,
        updatedCafe.id,
        updatedCafe.toInsertJson(),
      );

      if (data == null) return null;

      // Mettre à jour le cache
      final index =
          _cachedCafes.indexWhere((cafe) => cafe.id == updatedCafe.id);
      if (index != -1) {
        _cachedCafes[index] = Cafe.fromJson(data);
      }

      return Cafe.fromJson(data);
    } catch (e) {
      print('❌ Erreur dans CafeService.updateCafe: $e');
      return null;
    }
  }

  /// Nettoie le cache local
  void clearCache() {
    _cachedCafes.clear();
  }
}
