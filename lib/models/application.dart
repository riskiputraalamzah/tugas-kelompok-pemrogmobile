enum ApplicationStatus {
  pending,
  review,
  accepted,
  rejected,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Menunggu';
      case ApplicationStatus.review:
        return 'Sedang Ditinjau';
      case ApplicationStatus.accepted:
        return 'Diterima';
      case ApplicationStatus.rejected:
        return 'Ditolak';
    }
  }

  String get dbValue {
    return name;
  }

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

class Application {
  final String id;
  final String jobId;
  final String email;
  final String fullName;
  final String phone;
  final String education;
  final String experience;
  final String skills;
  final String coverLetter;
  final ApplicationStatus status;
  final double? aiScore;
  final String? aiLabel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Application({
    required this.id,
    required this.jobId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.education,
    required this.experience,
    required this.skills,
    required this.coverLetter,
    this.status = ApplicationStatus.pending,
    this.aiScore,
    this.aiLabel,
    required this.createdAt,
    this.updatedAt,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    // Safely convert aiScore - database might return int or double
    double? parseAiScore(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Application(
      id: map['id'] as String,
      jobId: map['job_id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      education: map['education'] as String,
      experience: map['experience'] as String,
      skills: map['skills'] as String,
      coverLetter: map['cover_letter'] as String,
      status: ApplicationStatusExtension.fromString(map['status'] as String),
      aiScore: parseAiScore(map['ai_score']),
      aiLabel: map['ai_label'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'education': education,
      'experience': experience,
      'skills': skills,
      'cover_letter': coverLetter,
      'status': status.dbValue,
      'ai_score': aiScore,
      'ai_label': aiLabel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Application copyWith({
    String? id,
    String? jobId,
    String? email,
    String? fullName,
    String? phone,
    String? education,
    String? experience,
    String? skills,
    String? coverLetter,
    ApplicationStatus? status,
    double? aiScore,
    String? aiLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Application(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      aiScore: aiScore ?? this.aiScore,
      aiLabel: aiLabel ?? this.aiLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
