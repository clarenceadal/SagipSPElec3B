abstract final class Validators {
  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) return requiredError;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? studentEmail(String? value) {
    final emailError = email(value);
    if (emailError != null) return emailError;

    if (!value!.trim().toLowerCase().endsWith('@usjr.edu.ph')) {
      return 'Use your USJ-R email ending in @usjr.edu.ph.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) {
      return 'Password must contain at least 8 characters.';
    }
    return null;
  }
}
