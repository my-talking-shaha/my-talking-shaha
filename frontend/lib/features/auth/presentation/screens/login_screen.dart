import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:go_router/go_router.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;

    return AuthScreenScaffold(
      useLoginBackground: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'My Talking\nShaha',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.primaryLight,
              fontSize: 46,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 52),
          AuthFormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(message: _errorMessage!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  AuthTextField(
                    label: 'Login',
                    controller: _loginController,
                    enabled: !isSubmitting,
                    hintText: 'Enter your login',
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                    validator: _requiredValidator('Enter your login'),
                    onChanged: (_) => _clearError(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextField(
                    label: 'Password',
                    controller: _passwordController,
                    enabled: !isSubmitting,
                    hintText: 'At least 8 characters',
                    helperText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
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
                    textInputAction: TextInputAction.done,
                    validator: _requiredValidator('Enter your password'),
                    onChanged: (_) => _clearError(),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isSubmitting ? null : () {},
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthPrimaryButton(
                    label: 'Log in',
                    isLoading: isSubmitting,
                    onPressed: _submit,
                    showArrow: true,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  const AuthSocialDivider(),
                  const SizedBox(height: AppSpacing.xxl),
                  AuthYandexButton(enabled: !isSubmitting),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'No account?',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => context.go('/registration'),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _requiredValidator(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
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
        .login(
          LoginCredentials(
            login: _loginController.text,
            password: _passwordController.text,
          ),
        );

    if (message == null || !mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
    });
  }
}
