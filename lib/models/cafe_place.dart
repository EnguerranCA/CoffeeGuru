import 'package:latlong2/latlong.dart';
import 'coffee_log.dart';

/// Modèle représentant un café (pour les calculs et l'affichage)
class Cafe {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final List<CoffeeType> availableCoffeeTypes;
  final CafeType type;
  final String? imageUrl;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.availableCoffeeTypes = const [],
    required this.type,
    this.imageUrl,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Crée un Cafe depuis un JSON (depuis Supabase)
  factory Cafe.fromJson(Map<String, dynamic> json) {
    // Récupérer les types de café disponibles
    List<CoffeeType> coffeeTypes = [];
    if (json['available_coffee_types'] != null) {
      final types = json['available_coffee_types'] as List<dynamic>;
      coffeeTypes = types
          .map((t) => CoffeeType.values.firstWhere(
                (type) => type.name == t['coffee_type'],
                orElse: () => CoffeeType.espresso,
              ))
          .toList();
    }

    return Cafe(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      availableCoffeeTypes: coffeeTypes,
      type: CafeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CafeType.cafe,
      ),
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convertit le Cafe en JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type.name,
      'image_url': imageUrl,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crée un JSON pour l'insertion (sans id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type.name,
      'image_url': imageUrl,
      'created_by': createdBy,
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
