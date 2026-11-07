import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ADDA / CLUBS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.blue),
            onPressed: () => _showCreateClubDialog(context),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildClubCard('Ludo Masters', '5,230 Members', 'The ultimate clan for Ludo pros!', AppColors.red),
          _buildClubCard('Dhaka Gamers', '1,200 Members', 'Friendly matches every evening.', AppColors.green),
          _buildClubCard('Night Owls', '800 Members', 'We play when the world sleeps.', AppColors.blue),
        ],
      ),
    );
  }

  Widget _buildClubCard(String name, String members, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            ),
            child: Center(
              child: Icon(Icons.groups, size: 50, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                      child: Text(members, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    child: const Text('JOIN CLUB'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateClubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Club'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(hintText: 'Club Name', filled: true, fillColor: AppColors.background)),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(hintText: 'Description', filled: true, fillColor: AppColors.background)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Club creation backend coming soon!')));
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}
