class CoffeeLog {
  final String id;
  final CoffeeType type;
  final CoffeeLocation location;
  final DateTime timestamp;

  CoffeeLog({
    required this.id,
    required this.type,
    required this.location,
    required this.timestamp,
  });

  // Pour faciliter la conversion en JSON si besoin plus tard
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'location': location.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    return CoffeeLog(
      id: json['id'],
      type: CoffeeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CoffeeType.espresso,
      ),
      location: CoffeeLocation.values.firstWhere(
        (e) => e.name == json['location'],
        orElse: () => CoffeeLocation.home,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum CoffeeType {
  espresso('Espresso', '☕', 63),
  cappuccino('Cappuccino', '🥤', 63),
  latte('Latte', '🥛', 63),
  americano('Americano', '☕', 94),
  macchiato('Macchiato', '🍵', 63),
  mocha('Mocha', '🍫', 95),
  flatWhite('Flat White', '☕', 130),
  cortado('Cortado', '☕', 63),
  coldBrew('Cold Brew', '🧊', 200),
  affogato('Affogato', '🍨', 63);

  final String displayName;
  final String emoji;
  final int caffeinemg; // Caféine en milligrammes

  const CoffeeType(this.displayName, this.emoji, this.caffeinemg);
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
