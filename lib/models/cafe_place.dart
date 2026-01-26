import 'package:latlong2/latlong.dart';

/// Modèle représentant un café
class Cafe {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String? phone;
  final List<String> openingHours;
  final double rating;
  final int reviewCount;
  final List<CoffeeType> availableCoffeeTypes;
  final CafeType type;
  final String? imageUrl;

  Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.openingHours = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.availableCoffeeTypes = const [],
    required this.type,
    this.imageUrl,
  });

  /// Crée un Cafe depuis un JSON (pour les APIs futures)
  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      phone: json['phone'] as String?,
      openingHours: (json['opening_hours'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      availableCoffeeTypes: (json['coffee_types'] as List<dynamic>?)
              ?.map((e) => CoffeeType.values.firstWhere(
                    (type) => type.name == e,
                    orElse: () => CoffeeType.espresso,
                  ))
              .toList() ??
          [],
      type: CafeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CafeType.cafe,
      ),
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convertit le Cafe en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'phone': phone,
      'opening_hours': openingHours,
      'rating': rating,
      'review_count': reviewCount,
      'coffee_types': availableCoffeeTypes.map((e) => e.name).toList(),
      'type': type.name,
      'image_url': imageUrl,
    };
  }

  /// Calcule la distance depuis une position donnée (en kilomètres)
  double distanceFrom(LatLng position) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, position, location);
  }

  /// Retourne une description textuelle de la distance
  String distanceTextFrom(LatLng position) {
    final dist = distanceFrom(position);
    if (dist < 1) {
      return '${(dist * 1000).round()} m';
    }
    return '${dist.toStringAsFixed(1)} km';
  }
}

/// Types de café disponibles
enum CoffeeType {
  espresso('Espresso', '☕'),
  americano('Americano', '☕'),
  cappuccino('Cappuccino', '🥤'),
  latte('Latte', '🥤'),
  mocha('Mocha', '🍫'),
  macchiato('Macchiato', '☕'),
  flatWhite('Flat White', '☕'),
  coldBrew('Cold Brew', '🧊'),
  frappe('Frappé', '🧊'),
  decaf('Décaféiné', '☕');

  final String displayName;
  final String emoji;

  const CoffeeType(this.displayName, this.emoji);
}

/// Types d'établissements
enum CafeType {
  cafe('Café', '☕'),
  restaurant('Restaurant', '🍽️'),
  bar('Bar', '🍷'),
  vendingMachine('Distributeur', '🏪'),
  bakery('Boulangerie', '🥐');

  final String displayName;
  final String emoji;

  const CafeType(this.displayName, this.emoji);
}
