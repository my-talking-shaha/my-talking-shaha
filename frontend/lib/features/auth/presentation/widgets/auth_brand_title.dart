import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/colors.dart';

final class AuthBrandTitle extends StatelessWidget {
  const AuthBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'My Talking\nShaha',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: AuthColors.primaryLight,
        fontSize: 42,
        fontWeight: FontWeight.w900,
        height: 1.12,
      ),
    );
  }
}
