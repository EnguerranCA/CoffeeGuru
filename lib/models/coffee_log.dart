class CoffeeLog {
  final String id;
  final String userId;
  final CoffeeType type;
  
  // Lieu : soit un CafePlace (établissement) soit une location privée
  final String? cafePlaceId;
  final CoffeeLocation? locationType;
  
  // Informations du CafePlace (si chargées depuis la DB)
  final String? cafePlaceName;
  
  final DateTime timestamp;
  final DateTime? createdAt;

  CoffeeLog({
    required this.id,
    required this.userId,
    required this.type,
    this.cafePlaceId,
    this.locationType,
    this.cafePlaceName,
    required this.timestamp,
    this.createdAt,
  }) : assert(
          cafePlaceId != null || locationType != null,
          'Either cafePlaceId or locationType must be provided',
        );

  /// Crée un CoffeeLog depuis un JSON (depuis Supabase)
  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    // Récupérer le nom du CafePlace si disponible
    String? cafePlaceName;
    if (json['cafe_places'] != null) {
      cafePlaceName = json['cafe_places']['name'] as String?;
    }

    return CoffeeLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: CoffeeType.values.firstWhere(
        (e) => e.name == json['coffee_type'],
        orElse: () => CoffeeType.espresso,
      ),
      cafePlaceId: json['cafe_place_id'] as String?,
      locationType: json['location_type'] != null
          ? CoffeeLocation.values.firstWhere(
              (e) => e.name == json['location_type'],
              orElse: () => CoffeeLocation.home,
            )
          : null,
      cafePlaceName: cafePlaceName,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convertit le CoffeeLog en JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'coffee_type': type.name,
      'cafe_place_id': cafePlaceId,
      'location_type': locationType?.name,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Crée un JSON pour l'insertion (sans id, created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'coffee_type': type.name,
      'cafe_place_id': cafePlaceId,
      'location_type': locationType?.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Retourne le nom d'affichage du lieu
  String getLocationDisplayName() {
    if (cafePlaceName != null) {
      return cafePlaceName!;
    }
    if (locationType != null) {
      return locationType!.displayName;
    }
    return 'Lieu inconnu';
  }

  /// Retourne l'emoji du lieu
  String getLocationEmoji() {
    if (cafePlaceId != null) {
      return '🏪'; // Pour les CafePlaces
    }
    if (locationType != null) {
      return locationType!.emoji;
    }
    return '❓';
  }

  CoffeeLog copyWith({
    String? id,
    String? userId,
    CoffeeType? type,
    String? cafePlaceId,
    CoffeeLocation? locationType,
    String? cafePlaceName,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return CoffeeLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cafePlaceId: cafePlaceId ?? this.cafePlaceId,
      locationType: locationType ?? this.locationType,
      cafePlaceName: cafePlaceName ?? this.cafePlaceName,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ANCIEN CODE - Garder pour rétrocompatibilité temporaire
  // Utilise locationType comme fallback pour l'ancien code
  CoffeeLocation get location => locationType ?? CoffeeLocation.cafe;
}

enum CoffeeType {
  espresso('Espresso', '☕'),
  americano('Americano', '☕'),
  cappuccino('Cappuccino', '🥤'),
  latte('Latte', '🥛'),
  mocha('Mocha', '🍫'),
  macchiato('Macchiato', '🍵'),
  flatWhite('Flat White', '☕'),
  cortado('Cortado', '☕'),
  coldBrew('Cold Brew', '🧊'),
  frappe('Frappé', '🧊'),
  decaf('Décaféiné', '☕'),
  affogato('Affogato', '🍨');

  final String displayName;
  final String emoji;

  const CoffeeType(this.displayName, this.emoji);
}

enum CoffeeLocation {
  home('Chez moi', '🏠'),
  friend('Chez un ami', '👥'),
  work('Au travail', '💼'),
  cafe('Au café', '🏪'),
  restaurant('Au restaurant', '🍽️');

  final String displayName;
  final String emoji;

  const CoffeeLocation(this.displayName, this.emoji);
}
