import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_profile.dart';
import 'student_profile_service.dart';

class SupabaseStudentProfileService implements StudentProfileService {
  SupabaseStudentProfileService(this._client);

  final SupabaseClient _client;

  @override
  Future<StudentProfile> getStudentProfile(String profileId) async {
    final user = _client.auth.currentUser;
    final student = await _client
        .from('students')
        .select('''
          student_id,
          last_name,
          first_name,
          middle_initial,
          birth_date,
          department,
          course,
          year_level,
          contact_number
        ''')
        .eq('profile_id', profileId)
        .single();

    return StudentProfile.fromJson(
      student: student,
      authEmail: user?.email ?? '',
    );
  }

  @override
  Future<void> updateStudentProfile({
    required String profileId,
    required String contactNumber,
    required String email,
  }) async {
    await _client
        .from('students')
        .update({'contact_number': contactNumber.trim()})
        .eq('profile_id', profileId);

    final currentEmail = _client.auth.currentUser?.email;
    if (currentEmail != null && currentEmail != email.trim()) {
      await _client.auth.updateUser(UserAttributes(email: email.trim()));
    }
  }
}
