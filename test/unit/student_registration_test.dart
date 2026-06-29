import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/features/auth/models/student_registration.dart';

void main() {
  group('StudentRegistration', () {
    test('formats full name using last name first', () {
      final registration = StudentRegistration(
        studentId: ' 20260001 ',
        lastName: ' Adal ',
        firstName: ' Clarence Anthony ',
        middleInitial: ' c ',
        birthDate: DateTime(2003, 12, 30),
        department: ' School of Computer Studies ',
        course: ' BSIT ',
        yearLevel: 3,
        contactNumber: ' 09664152740 ',
        email: 'clarence@usjr.edu.ph',
        password: 'password123',
      );

      expect(registration.fullName, 'Adal, Clarence Anthony C.');
    });

    test('creates clean metadata for Supabase sign up', () {
      final registration = StudentRegistration(
        studentId: ' 20260001 ',
        lastName: ' Adal ',
        firstName: ' Clarence ',
        middleInitial: '',
        birthDate: DateTime(2003, 12, 30),
        department: ' School of Computer Studies ',
        course: ' BSIT ',
        yearLevel: 3,
        contactNumber: ' 09664152740 ',
        email: 'clarence@usjr.edu.ph',
        password: 'password123',
      );

      expect(registration.birthDateIso, '2003-12-30');
      expect(registration.toMetadata(), {
        'student_id': '20260001',
        'full_name': 'Adal, Clarence',
        'last_name': 'Adal',
        'first_name': 'Clarence',
        'middle_initial': '',
        'birth_date': '2003-12-30',
        'department': 'School of Computer Studies',
        'course': 'BSIT',
        'year_level': 3,
        'contact_number': '09664152740',
      });
    });
  });
}
