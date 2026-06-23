enum UserRole { student, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  factory AppUser.fromProfile({
    required String userId,
    required String email,
    required Map<String, dynamic> profile,
  }) {
    return AppUser(
      id: userId,
      email: email,
      fullName: profile['full_name'] as String? ?? '',
      role: profile['role'] == 'admin' ? UserRole.admin : UserRole.student,
    );
  }
}
