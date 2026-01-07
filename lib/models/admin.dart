class Admin {
  final String id;
  final String username;
  final String passwordHash;
  final String fullName;
  final DateTime createdAt;

  Admin({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    required this.createdAt,
  });

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      fullName: map['full_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
