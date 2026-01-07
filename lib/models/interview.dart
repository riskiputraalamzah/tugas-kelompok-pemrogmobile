class Interview {
  final String id;
  final String applicationId;
  final DateTime scheduledAt;
  final String location;
  final String? notes;
  final bool isConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Interview({
    required this.id,
    required this.applicationId,
    required this.scheduledAt,
    required this.location,
    this.notes,
    this.isConfirmed = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Interview.fromMap(Map<String, dynamic> map) {
    return Interview(
      id: map['id'] as String,
      applicationId: map['application_id'] as String,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      location: map['location'] as String,
      notes: map['notes'] as String?,
      // Handle both boolean (Supabase) and integer (SQLite)
      isConfirmed: map['is_confirmed'] == true || map['is_confirmed'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'location': location,
      'notes': notes,
      'is_confirmed': isConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Interview copyWith({
    String? id,
    String? applicationId,
    DateTime? scheduledAt,
    String? location,
    String? notes,
    bool? isConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Interview(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
