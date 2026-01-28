/// Modèle représentant un utilisateur
class User {
  final String id;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée un User depuis un JSON (depuis Supabase)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertit le User en JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée un JSON pour l'insertion (sans id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'username': username,
    };
  }

  User copyWith({
    String? id,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
