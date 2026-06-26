import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';

final class AuthController extends AsyncNotifier<AuthSession?> {
  static const restoreSessionTimeout = Duration(seconds: 3);

  @override
  Future<AuthSession?> build() async {
    try {
      return await ref
          .watch(authRepositoryProvider)
          .restoreSession()
          .timeout(restoreSessionTimeout);
    } on TimeoutException {
      return null;
    }
  }

  Future<String?> register(RegistrationCredentials credentials) async {
    if (state.isLoading) {
      return null;
    }

    state = const AsyncLoading<AuthSession?>();

    try {
      final session =
          await ref.read(authRepositoryProvider).register(credentials);
      state = AsyncData(session);
      return null;
    } on AuthException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (_) {
      state = const AsyncData(null);
      return 'Something went wrong. Please try again later';
    }
  }

  Future<String?> login(LoginCredentials credentials) async {
    if (state.isLoading) {
      return null;
    }

    state = const AsyncLoading<AuthSession?>();

    try {
      final session = await ref.read(authRepositoryProvider).login(credentials);
      state = AsyncData(session);
      return null;
    } on AuthException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (_) {
      state = const AsyncData(null);
      return 'Something went wrong. Please try again later';
    }
  }

  Future<String?> logout() async {
    if (state.isLoading) {
      return null;
    }

    final previousSession = state.maybeWhen(
      data: (session) => session,
      orElse: () => null,
    );
    state = const AsyncLoading<AuthSession?>();

    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AsyncData(null);
      return null;
    } catch (_) {
      state = AsyncData(previousSession);
      return 'Could not log out. Please try again';
    }
  }
}
