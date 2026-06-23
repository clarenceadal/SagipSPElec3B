import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AuthExceptionMapper {
  static String message(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }
      if (message.contains('email not confirmed')) {
        return 'Confirm your email before signing in.';
      }
      if (message.contains('user already registered')) {
        return 'An account already exists for this email.';
      }
      if (message.contains('password')) {
        return error.message;
      }
      return error.message;
    }

    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'That student ID or account information is already registered.';
      }
      return 'The account was created, but the student profile could not be saved.';
    }

    return 'Something went wrong. Check your connection and try again.';
  }
}
