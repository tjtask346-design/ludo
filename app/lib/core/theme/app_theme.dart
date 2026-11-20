import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF20A65A);
  static const Color yellow = Color(0xFFFFC928);
  static const Color blue = Color(0xFF2878DB);
  static const Color blueLight = Color(0xFF68A8FF);
  static const Color background = Color(0xFF0F1423);
  static const Color card = Color(0xFF1A2235);
  static const Color textLight = Color(0xFF858585);
  static const Color textDark = Color(0xFF262626);
  static const Color border = Color(0xFFEAE5DC);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
