import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/data/datasources/auth_secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_session_storage.dart';
import 'package:frontend/features/auth/data/datasources/shared_preferences_auth_session_storage.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  if (kIsWeb) {
    return SharedPreferencesAuthSessionStorage(
      ref.watch(sharedPreferencesProvider),
    );
  }

  return SecureAuthSessionStorage(ref.watch(flutterSecureStorageProvider));
});

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthApiDatasource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(authDatasourceProvider),
    storage: ref.watch(authSessionStorageProvider),
  );
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(
      AuthController.new,
      retry: (_, _) => null,
    );
