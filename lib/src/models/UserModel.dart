// user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createAt; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createAt,
  });

  // Supabase
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'],
      createAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createAt: $createAt)';
  }
}
