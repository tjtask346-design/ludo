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
          _buildSectionTitle('GAMEPLAY'),
          _buildSwitchTile('Sound Effects', SettingsService.soundOn, (val) => setState(() => SettingsService.soundOn = val)),
          _buildSwitchTile('Background Music', SettingsService.musicOn, (val) => setState(() => SettingsService.musicOn = val)),
          _buildSwitchTile('Vibration', SettingsService.vibrationOn, (val) => setState(() => SettingsService.vibrationOn = val)),
          const Divider(height: 40),
          
          _buildSectionTitle('SUPPORT'),
          ListTile(
            leading: const Icon(Icons.help_center, color: AppColors.blue),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.blue),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.blue),
            title: const Text('App Version'),
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textLight)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1)),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      activeColor: AppColors.blue,
      onChanged: onChanged,
    );
  }
}
