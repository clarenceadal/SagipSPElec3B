import '../models/app_user.dart';
import '../models/student_registration.dart';

enum AuthSessionEvent {
  initialSession,
  signedIn,
  signedOut,
  passwordRecovery,
  userUpdated,
}

abstract interface class AuthService {
  Stream<AuthSessionEvent> get authEvents;

  bool get hasSession;

  Future<AppUser?> getCurrentUser();

  Future<AppUser> signIn({required String email, required String password});

  Future<bool> registerStudent(StudentRegistration registration);

  Future<void> sendPasswordReset(String email);

  Future<void> updatePassword(String password);

  Future<void> signOut();
}
