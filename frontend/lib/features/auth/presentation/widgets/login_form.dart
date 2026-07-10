import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/common/auth_form_card.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:frontend/features/auth/presentation/common/auth_primary_button.dart';
import 'package:frontend/features/auth/presentation/common/auth_text_field.dart';
import 'package:frontend/features/auth/presentation/utils/auth_form_utils.dart';
import 'package:frontend/features/auth/presentation/utils/login_form_state.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:frontend/features/auth/utils/validator.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.formState,
    required this.l10n,
    required this.isSubmitting,
    required this.onModeSelected,
    required this.onSubmit,
    required this.onFieldSubmitted,
    super.key,
  });

  final LoginFormState formState;
  final AppLocalizations l10n;
  final bool isSubmitting;
  final ValueChanged<AuthMode> onModeSelected;
  final VoidCallback onSubmit;
  final ValueChanged<String> onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      child: Form(
        key: formState.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthModeSwitch(
              selectedMode: AuthMode.login,
              onModeSelected: onModeSelected,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (formState.errorMessage case final message?) ...[
              AuthErrorBanner(message: message),
              const SizedBox(height: AppSpacing.lg),
            ],
            AuthTextField(
              label: l10n.email,
              controller: formState.loginController,
              enabled: !isSubmitting,
              hintText: l10n.enterYourEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidator.login(value, l10n),
              onChanged: formState.clearError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              label: l10n.password,
              controller: formState.passwordController,
              enabled: !isSubmitting,
              hintText: l10n.passwordHint,
              helperText: l10n.passwordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: formState.obscurePassword
                    ? l10n.showPassword
                    : l10n.hidePassword,
                onPressed: AuthFormUtils.enabledCallback(
                  isEnabled: !isSubmitting,
                  callback: formState.togglePasswordVisibility,
                ),
                icon: Icon(
                  formState.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              obscureText: formState.obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) => AuthValidator.password(value, l10n),
              onChanged: formState.clearError,
              onFieldSubmitted: onFieldSubmitted,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: AuthFormUtils.enabledCallback(
                  isEnabled: !isSubmitting,
                  callback: AuthFormUtils.noOp,
                ),
                child: Text(l10n.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AuthPrimaryButton(
              label: l10n.logIn,
              isLoading: isSubmitting,
              onPressed: onSubmit,
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }
}
