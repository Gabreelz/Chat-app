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
      name: m['name'] ?? 'Usuário', // Adicionado fallback
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

  // ADICIONADO: Método copyWith para facilitar atualizações de estado
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}