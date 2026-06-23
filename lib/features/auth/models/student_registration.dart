class StudentRegistration {
  const StudentRegistration({
    required this.studentId,
    required this.lastName,
    required this.firstName,
    required this.middleInitial,
    required this.birthDate,
    required this.department,
    required this.course,
    required this.yearLevel,
    required this.contactNumber,
    required this.email,
    required this.password,
  });

  final String studentId;
  final String lastName;
  final String firstName;
  final String middleInitial;
  final DateTime birthDate;
  final String department;
  final String course;
  final int yearLevel;
  final String contactNumber;
  final String email;
  final String password;

  String get fullName {
    final middle = middleInitial.trim().toUpperCase();
    return '${lastName.trim()}, ${firstName.trim()}'
        '${middle.isEmpty ? '' : ' $middle.'}';
  }

  String get birthDateIso {
    final month = birthDate.month.toString().padLeft(2, '0');
    final day = birthDate.day.toString().padLeft(2, '0');
    return '${birthDate.year}-$month-$day';
  }

  Map<String, Object> toMetadata() {
    return {
      'student_id': studentId.trim(),
      'full_name': fullName,
      'last_name': lastName.trim(),
      'first_name': firstName.trim(),
      'middle_initial': middleInitial.trim().toUpperCase(),
      'birth_date': birthDateIso,
      'department': department.trim(),
      'course': course.trim(),
      'year_level': yearLevel,
      'contact_number': contactNumber.trim(),
    };
  }
}
