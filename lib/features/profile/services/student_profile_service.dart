import '../models/student_profile.dart';

abstract interface class StudentProfileService {
  Future<StudentProfile> getStudentProfile(String profileId);

  Future<void> updateStudentProfile({
    required String profileId,
    required String contactNumber,
    required String email,
  });
}
