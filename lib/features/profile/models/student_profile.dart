class StudentProfile {
  const StudentProfile({
    required this.studentId,
    required this.fullName,
    required this.birthDate,
    required this.department,
    required this.course,
    required this.yearLevel,
    required this.contactNumber,
    required this.email,
  });

  final String studentId;
  final String fullName;
  final DateTime? birthDate;
  final String department;
  final String course;
  final int? yearLevel;
  final String contactNumber;
  final String email;

  StudentProfile copyWith({
    String? contactNumber,
    String? email,
  }) {
    return StudentProfile(
      studentId: studentId,
      fullName: fullName,
      birthDate: birthDate,
      department: department,
      course: course,
      yearLevel: yearLevel,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
    );
  }

  factory StudentProfile.fromJson({
    required Map<String, dynamic> student,
    required String authEmail,
  }) {
    final lastName = student['last_name'] as String?;
    final firstName = student['first_name'] as String?;
    final middleInitial = student['middle_initial'] as String?;
    final birthDateValue = student['birth_date'] as String?;

    final fullName = [
      if (lastName != null && lastName.trim().isNotEmpty) lastName.trim(),
      if (firstName != null && firstName.trim().isNotEmpty) firstName.trim(),
      if (middleInitial != null && middleInitial.trim().isNotEmpty)
        '${middleInitial.trim()}.',
    ].join(', ');

    return StudentProfile(
      studentId: student['student_id'] as String? ?? '',
      fullName: fullName.isEmpty ? 'Student' : fullName,
      birthDate: birthDateValue == null ? null : DateTime.tryParse(birthDateValue),
      department: student['department'] as String? ?? '',
      course: student['course'] as String? ?? '',
      yearLevel: student['year_level'] as int?,
      contactNumber: student['contact_number'] as String? ?? '',
      email: authEmail,
    );
  }
}
