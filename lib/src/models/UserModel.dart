// lib/src/models/UserModel.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'] ?? m['user_id'] ?? '',
      email: m['email'] ?? '',
      name: m['name'] ?? '',
      avatarUrl: m['avatar_url'],
      createdAt: m['created_at'] == null
          ? null
          : DateTime.parse(m['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
