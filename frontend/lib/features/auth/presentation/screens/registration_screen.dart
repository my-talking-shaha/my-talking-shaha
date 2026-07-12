import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:frontend/features/auth/presentation/utils/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/utils/registration_form_state.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:frontend/features/auth/presentation/widgets/registration_form.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

final class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formState = RegistrationFormState();

  @override
  void dispose() {
    _formState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting = ref.watch(authControllerProvider).isLoading;

    return ListenableBuilder(
      listenable: _formState,
      builder: (context, _) {
        return AuthScreenScaffold(
          child: RegistrationForm(
            formState: _formState,
            l10n: l10n,
            isSubmitting: isSubmitting,
            onModeSelected: AuthNavigation.modeSelectionCallback(
              context,
              AuthMode.register,
            ),
            onSubmit: _formState.submitCallback(ref, l10n),
            onFieldSubmitted: _formState.fieldSubmittedCallback(ref, l10n),
            onLogin: AuthNavigation.goToLoginCallback(context),
          ),
        );
      },
    );
  }
}
