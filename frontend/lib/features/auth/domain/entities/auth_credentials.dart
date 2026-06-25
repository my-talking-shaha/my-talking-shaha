final class LoginCredentials {
  const LoginCredentials({required this.login, required this.password});

  final String login;
  final String password;

  LoginCredentials trimmed() {
    return LoginCredentials(login: login.trim(), password: password.trim());
  }
}

final class RegistrationCredentials {
  const RegistrationCredentials({
    required this.fullName,
    required this.login,
    required this.password,
  });

  final String fullName;
  final String login;
  final String password;

  RegistrationCredentials trimmed() {
    return RegistrationCredentials(
      fullName: fullName.trim(),
      login: login.trim(),
      password: password.trim(),
    );
  }
}
