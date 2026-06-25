import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/data/datasources/auth_secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authSecureStorageProvider = Provider<AuthSecureStorage>((ref) {
  return AuthSecureStorage(ref.watch(flutterSecureStorageProvider));
});

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return MockAuthDatasource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(authDatasourceProvider),
    storage: ref.watch(authSecureStorageProvider),
  );
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(
  AuthController.new,
  retry: (_, _) => null,
);
