import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user.dart';
import 'database_service.dart';

/// Service d'authentification et de gestion d'utilisateur
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  
  User? _currentUser;
  bool _isGuest = true;
  String? _lastError; // Pour stocker le dernier message d'erreur
  
  // Clés pour SharedPreferences
  static const String _userIdKey = 'current_user_id';
  static const String _usernameKey = 'current_username';
  static const String _isGuestKey = 'is_guest';
  
  // ID utilisateur invité par défaut
  static const String guestUserId = '00000000-0000-0000-0000-000000000000';

  /// Initialise l'authentification au démarrage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isGuest = prefs.getBool(_isGuestKey) ?? true;
    
    if (_isGuest) {
      // Mode invité
      _currentUser = User(
        id: guestUserId,
        username: 'Invité',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      // Récupérer l'utilisateur connecté
      final userId = prefs.getString(_userIdKey);
      final username = prefs.getString(_usernameKey);
      
      if (userId != null && username != null) {
        // Tenter de récupérer depuis Supabase
        try {
          final userData = await _db.getById(DatabaseService.usersTable, userId);
          if (userData != null) {
            _currentUser = User.fromJson(userData);
          } else {
            // L'utilisateur n'existe plus, passer en mode invité
            await _setGuestMode();
          }
        } catch (e) {
          // Erreur de connexion, utiliser les données en cache
          _currentUser = User(
            id: userId,
            username: username,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Pas de données sauvegardées, passer en mode invité
        await _setGuestMode();
      }
    }
  }

  /// Définit le mode invité
  Future<void> _setGuestMode() async {
    _isGuest = true;
    _currentUser = User(
      id: guestUserId,
      username: 'Invité',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, true);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  /// Getters
  User? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => !_isGuest && _currentUser != null;
  String get currentUserId => _currentUser?.id ?? guestUserId;
  String? get lastError => _lastError;

  /// Connexion avec username et password
  Future<bool> login(String username, String password) async {
    _lastError = null;
    
    // Vérifier que la base de données est initialisée
    if (!_db.isInitialized) {
      _lastError = 'Base de données non disponible. Veuillez redémarrer l\'application.';
      print('❌ DatabaseService non initialisé lors de la tentative de login');
      return false;
    }
    
    try {
      // Rechercher l'utilisateur par username
      final response = await _db.client
          .from(DatabaseService.usersTable)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        _lastError = 'Utilisateur non trouvé';
        return false; // Utilisateur non trouvé
      }

      // Vérifier le mot de passe hashé
      final storedHash = response['password_hash'] as String?;
      if (storedHash == null || !BCrypt.checkpw(password, storedHash)) {
        _lastError = 'Mot de passe incorrect';
        return false; // Mot de passe incorrect
      }

      _currentUser = User.fromJson(response);
      _isGuest = false;

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isGuestKey, false);
      await prefs.setString(_userIdKey, _currentUser!.id);
      await prefs.setString(_usernameKey, _currentUser!.username);

      return true;
    } catch (e) {
      print('❌ Erreur lors de la connexion: $e');
      _lastError = 'Erreur de connexion: $e';
      return false;
    }
  }

  /// Inscription (créer un nouveau compte)
  Future<bool> signup(String username, String password) async {
    _lastError = null;
    
    // Vérifier que la base de données est initialisée
    if (!_db.isInitialized) {
      _lastError = 'Base de données non disponible. Veuillez redémarrer l\'application.';
      print('❌ DatabaseService non initialisé lors de la tentative de signup');
      return false;
    }
    
    try {
      print('🔍 Vérification si le username "$username" existe déjà...');
      
      // Vérifier si le username existe déjà
      final existing = await _db.client
          .from(DatabaseService.usersTable)
          .select()
          .eq('username', username)
          .maybeSingle();

      print('🔍 Résultat de la vérification: ${existing != null ? "EXISTE DÉJÀ" : "DISPONIBLE"}');
      
      if (existing != null) {
        print('❌ Username "$username" déjà pris');
        _lastError = 'Ce nom d\'utilisateur est déjà pris';
        return false; // Username déjà pris
      }

      print('🔐 Hashage du mot de passe...');
      // Hasher le mot de passe
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      print('💾 Création du nouvel utilisateur...');
      // Créer le nouvel utilisateur
      final userData = await _db.insert(
        DatabaseService.usersTable,
        {
          'username': username,
          'password_hash': passwordHash,
        },
      );

      if (userData == null) {
        print('❌ Échec de la création de l\'utilisateur');
        _lastError = 'Échec de la création du compte';
        return false;
      }

      print('✅ Utilisateur créé avec succès: ${userData['id']}');

      _currentUser = User.fromJson(userData);
      _isGuest = false;

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isGuestKey, false);
      await prefs.setString(_userIdKey, _currentUser!.id);
      await prefs.setString(_usernameKey, _currentUser!.username);

      return true;
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');
      _lastError = 'Erreur lors de l\'inscription: ${e.toString()}';
      
      // Si c'est une erreur de contrainte unique de Postgres
      if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
        _lastError = 'Ce nom d\'utilisateur est déjà pris';
      }
      
      return false;
    }
  }

  /// Déconnexion (retour en mode invité)
  Future<void> logout() async {
    await _setGuestMode();
  }

  /// Migrer les données du compte invité vers le compte connecté
  Future<void> migrateGuestData(String oldUserId, String newUserId) async {
    try {
      // Mettre à jour tous les coffee_logs de l'invité vers le nouvel utilisateur
      await _db.client
          .from(DatabaseService.coffeeLogsTable)
          .update({'user_id': newUserId})
          .eq('user_id', oldUserId);
      
      print('✅ Données migrées de $oldUserId vers $newUserId');
    } catch (e) {
      print('❌ Erreur lors de la migration des données: $e');
    }
  }

  /// Connexion/Inscription avec migration automatique des données
  Future<bool> loginOrSignup(String username, String password, {bool isSignup = false}) async {
    final oldUserId = currentUserId;
    final wasGuest = isGuest;
    
    bool success;
    if (isSignup) {
      success = await signup(username, password);
    } else {
      success = await login(username, password);
    }

    // Si succès et était invité, migrer les données
    if (success && wasGuest && oldUserId != guestUserId) {
      await migrateGuestData(oldUserId, currentUserId);
    }

    return success;
  }
}
