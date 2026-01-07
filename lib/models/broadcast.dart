class Broadcast {
  final String id;
  final String title;
  final String content;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Broadcast({
    required this.id,
    required this.title,
    required this.content,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Broadcast.fromMap(Map<String, dynamic> map) {
    return Broadcast(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      // Handle both boolean (Supabase) and integer (SQLite)
      isActive: map['is_active'] == true || map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Broadcast copyWith({
    String? id,
    String? title,
    String? content,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Broadcast(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
