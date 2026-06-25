final class LoginCredentials {
  const LoginCredentials({required this.email, required this.password});

  final String email;
  final String password;

  LoginCredentials trimmed() {
    return LoginCredentials(email: email.trim(), password: password.trim());
  }
}

final class RegistrationCredentials {
  const RegistrationCredentials({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;

  RegistrationCredentials trimmed() {
    return RegistrationCredentials(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password.trim(),
    );
  }
}
