abstract final class AuthValidator {
  static const int minPasswordLength = 8;

  static String? fullName(String? value) {
    return requiredField(value, message: 'Enter your full name');
  }

  static String? login(String? value) {
    return requiredField(value, message: 'Enter your login');
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, message: 'Enter your password');
    if (requiredError != null) {
      return requiredError;
    }

    if (!isStrongPassword(value!)) {
      return 'Password must be at least $minPasswordLength characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = requiredField(
      value,
      message: 'Confirm your password',
    );
    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? requiredField(String? value, {required String message}) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  static bool isStrongPassword(String password) {
    return password.trim().length >= minPasswordLength;
  }
}
