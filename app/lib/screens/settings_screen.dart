import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Vibration', style: TextStyle(color: Colors.white)),
            value: SettingsService.vibrationOn,
            activeColor: AppColors.blue,
            onChanged: (val) => setState(() => SettingsService.vibrationOn = val),
          ),
          SwitchListTile(
            title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
            value: SettingsService.soundOn,
            activeColor: AppColors.blue,
            onChanged: (val) => setState(() => SettingsService.soundOn = val),
          ),
        ],
      ),
    );
  }
}
