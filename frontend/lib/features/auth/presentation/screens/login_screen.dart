import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/presentation/common/auth_account_prompt.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:frontend/features/auth/presentation/utils/auth_form_utils.dart';
import 'package:frontend/features/auth/presentation/utils/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/utils/login_form_state.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:frontend/features/auth/presentation/widgets/login_form.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formState = LoginFormState();

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
          useLoginBackground: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthBrandTitle(),
              const SizedBox(height: AppSpacing.xxl),
              LoginForm(
                formState: _formState,
                l10n: l10n,
                isSubmitting: isSubmitting,
                onModeSelected: AuthNavigation.modeSelectionCallback(
                  context,
                  AuthMode.login,
                ),
                onSubmit: _formState.submitCallback(ref, l10n),
                onFieldSubmitted: _formState.fieldSubmittedCallback(ref, l10n),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthAccountPrompt(
                prompt: l10n.noAccount,
                actionLabel: l10n.register,
                onPressed: AuthFormUtils.enabledCallback(
                  isEnabled: !isSubmitting,
                  callback: AuthNavigation.goToRegistrationCallback(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
