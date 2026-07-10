import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(
  AuthController.new,
  retry: (_, _) => null,
);
