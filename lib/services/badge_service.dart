import 'package:flutter/material.dart';
import '../models/badge.dart' as badge_model;
import '../models/coffee_log.dart';
import 'coffee_service.dart';

/// Service pour gérer les badges et leur déblocage
class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  final CoffeeService _coffeeService = CoffeeService();

  /// Liste de tous les badges disponibles
  final List<badge_model.Badge> _allBadges = [
    // Badges de total
    badge_model.Badge(
      id: 'first_coffee',
      name: 'Premier Café',
      description: 'Buvez votre premier café',
      icon: Icons.local_cafe,
      color: const Color(0xFF8B4513),
      requiredValue: 1,
      type: badge_model.BadgeType.total,
    ),
    badge_model.Badge(
      id: 'coffee_addict',
      name: 'Accro au Café',
      description: 'Buvez 50 cafés',
      icon: Icons.local_cafe,
      color: const Color(0xFF6B4423),
      requiredValue: 50,
      type: badge_model.BadgeType.total,
    ),
    badge_model.Badge(
      id: 'coffee_master',
      name: 'Maître du Café',
      description: 'Buvez 100 cafés',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFD700),
      requiredValue: 100,
      type: badge_model.BadgeType.total,
    ),
    badge_model.Badge(
      id: 'coffee_legend',
      name: 'Légende du Café',
      description: 'Buvez 500 cafés',
      icon: Icons.star,
      color: const Color(0xFFFF6B6B),
      requiredValue: 500,
      type: badge_model.BadgeType.total,
    ),

    // Badges de streak (jours consécutifs)
    badge_model.Badge(
      id: 'streak_3',
      name: 'Régulier',
      description: 'Buvez du café pendant 3 jours consécutifs',
      icon: Icons.whatshot,
      color: const Color(0xFFFF6B35),
      requiredValue: 3,
      type: badge_model.BadgeType.streak,
    ),
    badge_model.Badge(
      id: 'streak_7',
      name: 'Dédié',
      description: 'Buvez du café pendant 7 jours consécutifs',
      icon: Icons.whatshot,
      color: const Color(0xFFFF4500),
      requiredValue: 7,
      type: badge_model.BadgeType.streak,
    ),
    badge_model.Badge(
      id: 'streak_30',
      name: 'Inarrêtable',
      description: 'Buvez du café pendant 30 jours consécutifs',
      icon: Icons.whatshot,
      color: const Color(0xFFDC143C),
      requiredValue: 30,
      type: badge_model.BadgeType.streak,
    ),

    // Badges de variété
    badge_model.Badge(
      id: 'variety_5',
      name: 'Curieux',
      description: 'Essayez 5 types de café différents',
      icon: Icons.coffee,
      color: const Color(0xFF9C27B0),
      requiredValue: 5,
      type: badge_model.BadgeType.variety,
    ),
    badge_model.Badge(
      id: 'variety_10',
      name: 'Connaisseur',
      description: 'Essayez 10 types de café différents',
      icon: Icons.coffee,
      color: const Color(0xFF7B1FA2),
      requiredValue: 10,
      type: badge_model.BadgeType.variety,
    ),

    // Badges d'explorateur
    badge_model.Badge(
      id: 'explorer_5',
      name: 'Caf\'explorateur',
      description: 'Visitez 5 endroits différents',
      icon: Icons.explore,
      color: const Color(0xFF2196F3),
      requiredValue: 5,
      type: badge_model.BadgeType.explorer,
    ),
    badge_model.Badge(
      id: 'explorer_20',
      name: 'Globe-trotter du Café',
      description: 'Visitez 20 endroits différents',
      icon: Icons.explore,
      color: const Color(0xFF1976D2),
      requiredValue: 20,
      type: badge_model.BadgeType.explorer,
    ),

    // Badges spéciaux
    badge_model.Badge(
      id: 'early_bird',
      name: 'Lève-tôt',
      description: 'Buvez 10 cafés avant 8h du matin',
      icon: Icons.wb_sunny,
      color: const Color(0xFFFFA726),
      requiredValue: 10,
      type: badge_model.BadgeType.speed,
    ),
    badge_model.Badge(
      id: 'night_owl',
      name: 'Oiseau de nuit',
      description: 'Buvez 10 cafés après 22h',
      icon: Icons.nights_stay,
      color: const Color(0xFF5E35B1),
      requiredValue: 10,
      type: badge_model.BadgeType.night,
    ),
  ];

  /// Récupère tous les badges avec leur statut de déblocage
  Future<List<badge_model.Badge>> getAllBadges() async {
    final logs = await _coffeeService.getCoffeeLogs();
    
    for (var badge in _allBadges) {
      final progress = await _calculateProgress(badge, logs);
      badge.isUnlocked = progress >= badge.requiredValue;
    }
    
    return _allBadges;
  }

  /// Récupère uniquement les badges débloqués
  Future<List<badge_model.Badge>> getUnlockedBadges() async {
    final allBadges = await getAllBadges();
    return allBadges.where((badge) => badge.isUnlocked).toList();
  }

  /// Calcule la progression pour un badge donné
  Future<int> _calculateProgress(badge_model.Badge badge, List<CoffeeLog> logs) async {
    switch (badge.type) {
      case badge_model.BadgeType.total:
        return logs.length;

      case badge_model.BadgeType.streak:
        return _calculateStreak(logs);

      case badge_model.BadgeType.variety:
        return logs.map((log) => log.type).toSet().length;

      case badge_model.BadgeType.explorer:
        return logs
            .map((log) => log.cafePlaceId ?? log.locationType ?? 'unknown')
            .toSet()
            .length;

      case badge_model.BadgeType.speed:
        return logs.where((log) {
          final hour = log.timestamp.hour;
          return hour < 8;
        }).length;

      case badge_model.BadgeType.night:
        return logs.where((log) {
          final hour = log.timestamp.hour;
          return hour >= 22;
        }).length;
    }
  }

  /// Calcule le streak actuel (jours consécutifs avec au moins un café)
  int _calculateStreak(List<CoffeeLog> logs) {
    if (logs.isEmpty) return 0;

    final sortedLogs = logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final today = DateTime.now();
    final uniqueDays = <DateTime>{};

    for (var log in sortedLogs) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      uniqueDays.add(logDate);
    }

    final sortedDays = uniqueDays.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? expectedDate = DateTime(today.year, today.month, today.day);

    for (var day in sortedDays) {
      if (expectedDate == null) break;

      if (day.isAtSameMomentAs(expectedDate) ||
          day.isAtSameMomentAs(expectedDate.subtract(const Duration(days: 1)))) {
        streak++;
        expectedDate = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Récupère la progression pour un badge spécifique
  Future<double> getProgressForBadge(badge_model.Badge badge) async {
    final logs = await _coffeeService.getCoffeeLogs();
    final progress = await _calculateProgress(badge, logs);
    return (progress / badge.requiredValue).clamp(0.0, 1.0);
  }

  /// Vérifie les nouveaux badges débloqués et retourne la liste
  Future<List<badge_model.Badge>> checkNewlyUnlockedBadges() async {
    final allBadges = await getAllBadges();
    final newlyUnlocked = <badge_model.Badge>[];

    for (var badge in allBadges) {
      if (badge.isUnlocked && badge.unlockedAt == null) {
        badge.unlockedAt = DateTime.now();
        newlyUnlocked.add(badge);
      }
    }

    return newlyUnlocked;
  }
}
