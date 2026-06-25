import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_error_banner.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'My Talking Shaha',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Log in to continue to your garage.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    if (_errorMessage != null) ...[
                      AuthErrorBanner(message: _errorMessage!),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    TextFormField(
                      controller: _loginController,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.account_circle_outlined),
                      ),
                      validator: _requiredValidator('Enter your login'),
                      onChanged: (_) => _clearError(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !isSubmitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      ),
                      validator: _requiredValidator('Enter your password'),
                      onChanged: (_) => _clearError(),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => context.go('/registration'),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

    final message = await ref.read(authControllerProvider.notifier).login(
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
