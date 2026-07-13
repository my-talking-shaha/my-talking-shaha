String settingsProfileName({
  required String? fullName,
  required String? login,
  required String fallback,
}) {
  final normalizedFullName = fullName?.trim();
  if (normalizedFullName != null && normalizedFullName.isNotEmpty) {
    return normalizedFullName;
  }

  final normalizedLogin = login?.trim();
  if (normalizedLogin != null && normalizedLogin.isNotEmpty) {
    return normalizedLogin;
  }

  return fallback;
}

String settingsProfileLogin({
  required String? login,
  required String fallback,
}) {
  final normalizedLogin = login?.trim();
  return normalizedLogin == null || normalizedLogin.isEmpty
      ? fallback
      : normalizedLogin;
}

String settingsInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
