class Job {
  final String id;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String salaryRange;
  final String employmentType;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.salaryRange,
    required this.employmentType,
    this.isOpen = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      requirements: map['requirements'] as String,
      location: map['location'] as String,
      salaryRange: map['salary_range'] as String,
      employmentType: map['employment_type'] as String,
      // Handle both boolean (Supabase) and integer (SQLite) formats
      isOpen: map['is_open'] == true || map['is_open'] == 1,
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
      'description': description,
      'requirements': requirements,
      'location': location,
      'salary_range': salaryRange,
      'employment_type': employmentType,
      'is_open': isOpen, // Supabase uses boolean directly
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? requirements,
    String? location,
    String? salaryRange,
    String? employmentType,
    bool? isOpen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      employmentType: employmentType ?? this.employmentType,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
