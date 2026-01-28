import 'database_service.dart';

/// Modèle pour une entrée du classement
class LeaderboardEntry {
  final String userId;
  final String username;
  final int value;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.value,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      value: json['value'] as int,
      rank: rank,
    );
  }
}

/// Service pour gérer les classements
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final DatabaseService _db = DatabaseService();

  /// Obtient le classement par consommation totale de café
  Future<List<LeaderboardEntry>> getTotalConsumptionLeaderboard() async {
    try {
      final response = await _db.client
          .from(DatabaseService.coffeeLogsTable)
          .select('user_id, users!inner(username)')
          .neq('user_id', '00000000-0000-0000-0000-000000000000'); // Exclure l'invité

      // Grouper par utilisateur et compter
      final Map<String, Map<String, dynamic>> userCounts = {};
      
      for (var log in response) {
        final userId = log['user_id'] as String;
        final username = log['users']['username'] as String;
        
        if (!userCounts.containsKey(userId)) {
          userCounts[userId] = {
            'user_id': userId,
            'username': username,
            'value': 0,
          };
        }
        userCounts[userId]!['value'] = (userCounts[userId]!['value'] as int) + 1;
      }

      // Convertir en liste et trier
      final entries = userCounts.values.toList()
        ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

      // Ajouter les rangs
      return entries.asMap().entries.map((entry) {
        return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
      }).toList();
    } catch (e) {
      print('❌ Erreur getTotalConsumptionLeaderboard: $e');
      return [];
    }
  }

  /// Obtient le classement par nombre d'endroits différents visités
  Future<List<LeaderboardEntry>> getPlacesVisitedLeaderboard() async {
    try {
      final response = await _db.client.rpc('get_places_visited_leaderboard');
      
      return (response as List).asMap().entries.map((entry) {
        return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
      }).toList();
    } catch (e) {
      print('❌ Erreur getPlacesVisitedLeaderboard: $e');
      
      // Fallback si la fonction RPC n'existe pas
      try {
        final response = await _db.client
            .from(DatabaseService.coffeeLogsTable)
            .select('user_id, cafe_place_id, location_type, users!inner(username)')
            .neq('user_id', '00000000-0000-0000-0000-000000000000');

        // Grouper par utilisateur et compter les lieux uniques
        final Map<String, Map<String, dynamic>> userPlaces = {};
        
        for (var log in response) {
          final userId = log['user_id'] as String;
          final username = log['users']['username'] as String;
          final cafePlaceId = log['cafe_place_id'] as String?;
          final locationType = log['location_type'] as String?;
          
          // Créer un identifiant unique pour le lieu
          final locationKey = cafePlaceId ?? locationType ?? 'unknown';
          
          if (!userPlaces.containsKey(userId)) {
            userPlaces[userId] = {
              'user_id': userId,
              'username': username,
              'places': <String>{},
            };
          }
          (userPlaces[userId]!['places'] as Set<String>).add(locationKey);
        }

        // Convertir en liste avec le nombre de lieux
        final entries = userPlaces.entries.map((entry) {
          return {
            'user_id': entry.key,
            'username': entry.value['username'],
            'value': (entry.value['places'] as Set<String>).length,
          };
        }).toList()
          ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

        return entries.asMap().entries.map((entry) {
          return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
        }).toList();
      } catch (e2) {
        print('❌ Erreur fallback getPlacesVisitedLeaderboard: $e2');
        return [];
      }
    }
  }

  /// Obtient le classement par nombre de recettes différentes goûtées
  Future<List<LeaderboardEntry>> getCoffeeTypesLeaderboard() async {
    try {
      final response = await _db.client.rpc('get_coffee_types_leaderboard');
      
      return (response as List).asMap().entries.map((entry) {
        return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
      }).toList();
    } catch (e) {
      print('❌ Erreur getCoffeeTypesLeaderboard: $e');
      
      // Fallback si la fonction RPC n'existe pas
      try {
        final response = await _db.client
            .from(DatabaseService.coffeeLogsTable)
            .select('user_id, coffee_type, users!inner(username)')
            .neq('user_id', '00000000-0000-0000-0000-000000000000');

        // Grouper par utilisateur et compter les types uniques
        final Map<String, Map<String, dynamic>> userTypes = {};
        
        for (var log in response) {
          final userId = log['user_id'] as String;
          final username = log['users']['username'] as String;
          final coffeeType = log['coffee_type'] as String;
          
          if (!userTypes.containsKey(userId)) {
            userTypes[userId] = {
              'user_id': userId,
              'username': username,
              'types': <String>{},
            };
          }
          (userTypes[userId]!['types'] as Set<String>).add(coffeeType);
        }

        // Convertir en liste avec le nombre de types
        final entries = userTypes.entries.map((entry) {
          return {
            'user_id': entry.key,
            'username': entry.value['username'],
            'value': (entry.value['types'] as Set<String>).length,
          };
        }).toList()
          ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

        return entries.asMap().entries.map((entry) {
          return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
        }).toList();
      } catch (e2) {
        print('❌ Erreur fallback getCoffeeTypesLeaderboard: $e2');
        return [];
      }
    }
  }
}
