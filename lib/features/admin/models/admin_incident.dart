class AdminIncident {
  const AdminIncident({
    required this.id,
    required this.emergencyType,
    required this.status,
    required this.createdAt,
    required this.studentName,
    required this.studentId,
    required this.location,
    this.course,
    this.yearLevel,
    this.description,
  });

  final String id;
  final String emergencyType;
  final String status;
  final DateTime createdAt;
  final String studentName;
  final String studentId;
  final String location;
  final String? course;
  final int? yearLevel;
  final String? description;

  bool get isActive => status.toLowerCase() != 'resolved';

  factory AdminIncident.fromJson(Map<String, dynamic> json) {
    final student = json['students'] as Map<String, dynamic>? ?? {};
    final emergencyType = json['emergency_types'] as Map<String, dynamic>? ?? {};
    final locationAddress = json['location_address'] as String?;

    final firstName = student['first_name'] as String?;
    final lastName = student['last_name'] as String?;
    final middleInitial = student['middle_initial'] as String?;

    final nameParts = [
      if (lastName != null && lastName.trim().isNotEmpty) lastName.trim(),
      if (firstName != null && firstName.trim().isNotEmpty) firstName.trim(),
      if (middleInitial != null && middleInitial.trim().isNotEmpty)
        '${middleInitial.trim()}.',
    ];

    return AdminIncident(
      id: json['id'] as String,
      emergencyType: emergencyType['name'] as String? ?? 'Emergency Report',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      studentName: nameParts.isEmpty ? 'Student' : nameParts.join(', '),
      studentId: student['student_id'] as String? ?? 'Unknown ID',
      location: locationAddress?.trim().isNotEmpty == true
          ? locationAddress!.trim()
          : 'Location not captured yet',
      course: student['course'] as String?,
      yearLevel: student['year_level'] as int?,
      description: json['description'] as String?,
    );
  }
}
