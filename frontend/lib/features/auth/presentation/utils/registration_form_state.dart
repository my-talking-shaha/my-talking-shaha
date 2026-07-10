import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/presentation/utils/auth_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class RegistrationFormState extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool obscurePassword = true;
  bool _isDisposed = false;

  void clearError(String _) {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  VoidCallback submitCallback(WidgetRef ref, AppLocalizations l10n) {
    return () => unawaited(submit(ref, l10n));
  }

  ValueChanged<String> fieldSubmittedCallback(
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return (_) => unawaited(submit(ref, l10n));
  }

  Future<void> submit(WidgetRef ref, AppLocalizations l10n) async {
    if (!formKey.currentState!.validate()) return;

    final message = await ref
        .read(authControllerProvider.notifier)
        .register(
          RegistrationCredentials(
            fullName: fullNameController.text,
            login: loginController.text,
            password: passwordController.text,
          ),
        );

    if (message == null || _isDisposed) return;
    errorMessage = AuthFormUtils.localizedErrorMessage(l10n, message);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    fullNameController.dispose();
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
