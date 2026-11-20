import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_dashboard_screen.dart';

void main() => runApp(const BullaLudoApp());

class BullaLudoApp extends StatelessWidget {
  const BullaLudoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulla Ludo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainDashboardScreen(),
    );
  }
}
