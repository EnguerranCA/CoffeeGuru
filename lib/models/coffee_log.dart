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
  espresso('Espresso', '☕'),
  cappuccino('Cappuccino', '🥤'),
  latte('Latte', '🥛'),
  americano('Americano', '☕'),
  macchiato('Macchiato', '🍵'),
  mocha('Mocha', '🍫'),
  flatWhite('Flat White', '☕'),
  cortado('Cortado', '☕'),
  coldBrew('Cold Brew', '🧊'),
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
