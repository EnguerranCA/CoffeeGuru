import 'package:flutter/material.dart';

/// Modèle représentant un badge déblocable
class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredValue;
  final BadgeType type;
  bool isUnlocked;
  DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: _iconFromString(json['icon'] as String),
      color: Color(json['color'] as int),
      requiredValue: json['required_value'] as int,
      type: BadgeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BadgeType.total,
      ),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconToString(icon),
      'color': color.value,
      'required_value': requiredValue,
      'type': type.name,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  static IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'local_cafe':
        return Icons.local_cafe;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'whatshot':
        return Icons.whatshot;
      case 'explore':
        return Icons.explore;
      case 'coffee':
        return Icons.coffee;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nights_stay':
        return Icons.nights_stay;
      case 'restaurant':
        return Icons.restaurant;
      case 'star':
        return Icons.star;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.emoji_events;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.local_cafe) return 'local_cafe';
    if (icon == Icons.emoji_events) return 'emoji_events';
    if (icon == Icons.whatshot) return 'whatshot';
    if (icon == Icons.explore) return 'explore';
    if (icon == Icons.coffee) return 'coffee';
    if (icon == Icons.wb_sunny) return 'wb_sunny';
    if (icon == Icons.nights_stay) return 'nights_stay';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.star) return 'star';
    if (icon == Icons.speed) return 'speed';
    return 'emoji_events';
  }
}

/// Types de badges basés sur différents critères
enum BadgeType {
  total, // Nombre total de cafés
  streak, // Jours consécutifs
  variety, // Variété de types de café
  explorer, // Nombre de lieux différents
  speed, // Premier café de la journée
  night, // Café tardif
}
