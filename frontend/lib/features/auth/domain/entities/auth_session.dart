final class AuthSession {
  const AuthSession({
    required this.token,
    required this.email,
    required this.fullName,
  });

  final String token;
  final String email;
  final String fullName;
}
