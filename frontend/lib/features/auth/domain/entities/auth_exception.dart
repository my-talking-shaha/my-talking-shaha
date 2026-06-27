enum AuthErrorCode { validation, conflict, unauthorized, network, unknown }

final class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final AuthErrorCode code;
  final String message;
}
