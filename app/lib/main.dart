import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const BullaLudoApp());

class BullaLudoApp extends StatelessWidget {
  const BullaLudoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulla Ludo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5AF19), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
