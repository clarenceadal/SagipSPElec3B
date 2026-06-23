import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/student_registration.dart';
import 'auth_service.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthSessionEvent> get authEvents {
    return _client.auth.onAuthStateChange.map((state) {
      return switch (state.event) {
        AuthChangeEvent.signedIn => AuthSessionEvent.signedIn,
        AuthChangeEvent.signedOut => AuthSessionEvent.signedOut,
        AuthChangeEvent.passwordRecovery => AuthSessionEvent.passwordRecovery,
        AuthChangeEvent.userUpdated => AuthSessionEvent.userUpdated,
        _ => AuthSessionEvent.initialSession,
      };
    });
  }

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    await _ensureStudentRecord(user);

    final profile = await _client
        .from('profiles')
        .select('full_name, role')
        .eq('id', user.id)
        .single();

    return AppUser.fromProfile(
      userId: user.id,
      email: user.email ?? '',
      profile: profile,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = await getCurrentUser();
    if (user == null) {
      throw const AuthException('The session could not be created.');
    }
    return user;
  }

  @override
  Future<bool> registerStudent(StudentRegistration registration) async {
    final response = await _client.auth.signUp(
      email: registration.email.trim(),
      password: registration.password,
      data: registration.toMetadata(),
    );

    if (response.user == null) {
      throw const AuthException('The account could not be created.');
    }

    if (response.session != null) {
      await _ensureStudentRecord(response.user!);
      return false;
    }

    return true;
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: Uri.base.origin,
    );
  }

  @override
  Future<void> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<void> _ensureStudentRecord(User user) async {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final studentId = metadata['student_id']?.toString();
    final course = metadata['course']?.toString();
    final department = metadata['department']?.toString();
    final yearLevelValue = metadata['year_level'];
    final lastName = metadata['last_name']?.toString();
    final firstName = metadata['first_name']?.toString();
    final middleInitial = metadata['middle_initial']?.toString();
    final birthDate = metadata['birth_date']?.toString();

    if (studentId == null || course == null || yearLevelValue == null) {
      return;
    }

    final existing = await _client
        .from('students')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

    if (existing != null) return;

    final yearLevel = yearLevelValue is int
        ? yearLevelValue
        : int.parse(yearLevelValue.toString());

    try {
      await _client.from('students').insert({
        'profile_id': user.id,
        'student_id': studentId,
        'course': course,
        'department': department,
        'year_level': yearLevel,
        'last_name': lastName,
        'first_name': firstName,
        'middle_initial': middleInitial?.isEmpty == true ? null : middleInitial,
        'birth_date': birthDate,
      });
    } on PostgrestException catch (error) {
      // Sign-up and auth-state refresh can complete at nearly the same time.
      // A duplicate means the other request already completed the profile.
      if (error.code != '23505') rethrow;
    }
  }
}
