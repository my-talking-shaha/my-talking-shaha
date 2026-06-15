import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

class CarApp extends StatelessWidget {
  const CarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const Scaffold(body: Center(child: Text('Main page here'))),
    );
  }
}
