import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFE53935);
  static const Color redLight = Color(0xFFFF6B65);
  static const Color green = Color(0xFF20A65A);
  static const Color greenLight = Color(0xFF61D98B);
  static const Color yellow = Color(0xFFFFC928);
  static const Color yellowLight = Color(0xFFFFE477);
  static const Color blue = Color(0xFF2878DB);
  static const Color blueLight = Color(0xFF68A8FF);
  
  static const Color background = Color(0xFFFFF9ED);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF262626);
  static const Color textLight = Color(0xFF858585);
  static const Color border = Color(0xFFEAE5DC);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.blue,
      fontFamily: 'Nunito', // Default fallback if not added to pubspec
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }
}
