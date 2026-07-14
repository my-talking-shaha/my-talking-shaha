import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/common/auth_account_prompt.dart';
import 'package:frontend/features/auth/presentation/common/auth_form_card.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:frontend/features/auth/presentation/common/auth_primary_button.dart';
import 'package:frontend/features/auth/presentation/common/auth_text_field.dart';
import 'package:frontend/features/auth/presentation/utils/auth_form_utils.dart';
import 'package:frontend/features/auth/presentation/utils/registration_form_state.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:frontend/features/auth/utils/validator.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class RegistrationForm extends StatelessWidget {
  const RegistrationForm({
    required this.formState,
    required this.l10n,
    required this.isSubmitting,
    required this.onModeSelected,
    required this.onSubmit,
    required this.onFieldSubmitted,
    required this.onLogin,
    super.key,
  });

  final RegistrationFormState formState;
  final AppLocalizations l10n;
  final bool isSubmitting;
  final ValueChanged<AuthMode> onModeSelected;
  final VoidCallback onSubmit;
  final ValueChanged<String> onFieldSubmitted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      child: Form(
        key: formState.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthModeSwitch(
              selectedMode: AuthMode.register,
              onModeSelected: onModeSelected,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              l10n.registration,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.createYourProfile,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (formState.errorMessage case final message?) ...[
              AuthErrorBanner(message: message),
              const SizedBox(height: AppSpacing.lg),
            ],
            AuthTextField(
              label: l10n.fullName,
              controller: formState.fullNameController,
              enabled: !isSubmitting,
              hintText: l10n.fullNameHint,
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidator.fullName(value, l10n),
              onChanged: formState.clearError,
            ),
            const SizedBox(height: AppSpacing.lg),
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
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidator.password(value, l10n),
              onChanged: formState.clearError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              label: l10n.confirmPassword,
              controller: formState.confirmPasswordController,
              enabled: !isSubmitting,
              hintText: l10n.repeatPassword,
              prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
              obscureText: formState.obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) => AuthValidator.confirmPassword(
                value,
                formState.passwordController.text,
                l10n,
              ),
              onChanged: formState.clearError,
              onFieldSubmitted: onFieldSubmitted,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AuthPrimaryButton(
              label: l10n.register,
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AuthAccountPrompt(
              prompt: l10n.alreadyHaveAccount,
              actionLabel: l10n.logIn,
              onPressed: AuthFormUtils.enabledCallback(
                isEnabled: !isSubmitting,
                callback: onLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
