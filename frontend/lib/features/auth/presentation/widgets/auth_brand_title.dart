import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';

final class AuthBrandTitle extends StatelessWidget {
  const AuthBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'My Talking\nShaha',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: context.appColors.primaryLight,
        fontSize: 42,
        fontWeight: FontWeight.w900,
        height: 1.12,
      ),
    );
  }
}
