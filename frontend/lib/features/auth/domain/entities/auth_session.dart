final class AuthSession {
  const AuthSession({
    required this.token,
    required this.login,
    required this.fullName,
  });

  final String token;
  final String login;
  final String fullName;
}
