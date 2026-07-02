import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:frontend/features/auth/utils/validator.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

final class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;

    return AuthScreenScaffold(
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_errorMessage != null) ...[
                AuthErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AuthTextField(
                label: l10n.fullName,
                controller: _fullNameController,
                enabled: !isSubmitting,
                hintText: l10n.fullNameHint,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.fullName(value, l10n),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: l10n.email,
                controller: _loginController,
                enabled: !isSubmitting,
                hintText: l10n.enterYourEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.login(value, l10n),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: l10n.password,
                controller: _passwordController,
                enabled: !isSubmitting,
                hintText: l10n.passwordHint,
                helperText: l10n.passwordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? l10n.showPassword
                      : l10n.hidePassword,
                  onPressed: isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.password(value, l10n),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: l10n.confirmPassword,
                controller: _confirmPasswordController,
                enabled: !isSubmitting,
                hintText: l10n.repeatPassword,
                prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: (value) => AuthValidator.confirmPassword(
                  value,
                  _passwordController.text,
                  l10n,
                ),
                onChanged: (_) => _clearError(),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthPrimaryButton(
                label: l10n.register,
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: isSubmitting ? null : () => context.go('/login'),
                    child: Text(l10n.logIn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final message = await ref
        .read(authControllerProvider.notifier)
        .register(
          RegistrationCredentials(
            fullName: _fullNameController.text,
            login: _loginController.text,
            password: _passwordController.text,
          ),
        );

    if (message == null || !mounted) {
      return;
    }

    setState(() {
      _errorMessage = _localizedErrorMessage(context, message);
    });
  }

  String _localizedErrorMessage(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    return switch (message) {
      'Something went wrong. Please try again later' => l10n.somethingWentWrong,
      _ => message,
    };
  }
}
