import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/features/auth/models/app_user.dart';

void main() {
  group('AppUser', () {
    test('maps admin profile role to admin user role', () {
      final user = AppUser.fromProfile(
        userId: 'admin-id',
        email: 'ssd.admin@usjr.edu.ph',
        profile: {
          'full_name': 'SSD Administrator',
          'role': 'admin',
        },
      );

      expect(user.id, 'admin-id');
      expect(user.fullName, 'SSD Administrator');
      expect(user.role, UserRole.admin);
    });

    test('defaults unknown profile role to student user role', () {
      final user = AppUser.fromProfile(
        userId: 'student-id',
        email: 'student@usjr.edu.ph',
        profile: {
          'full_name': 'Adal, Clarence',
          'role': 'student',
        },
      );

      expect(user.role, UserRole.student);
    });
  });
}
