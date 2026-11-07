import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class DailyRewardsScreen extends StatefulWidget {
  const DailyRewardsScreen({super.key});
  @override
  State<DailyRewardsScreen> createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> {
  int currentDay = 3; // Mock data: player is on day 3

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('DAILY REWARDS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Claim your daily free rewards!', style: TextStyle(fontSize: 18, color: AppColors.textLight)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  int day = index + 1;
                  bool isClaimed = day < currentDay;
                  bool isCurrent = day == currentDay;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.card : AppColors.card.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isCurrent ? AppColors.blue : AppColors.border, width: 2),
                      boxShadow: isCurrent ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.2), blurRadius: 10)] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Day $day', style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? AppColors.blue : AppColors.textLight)),
                        const SizedBox(height: 10),
                        Icon(
                          day % 3 == 0 ? Icons.diamond : Icons.monetization_on,
                          size: 40,
                          color: day % 3 == 0 ? AppColors.blue : AppColors.yellow,
                        ),
                        const SizedBox(height: 10),
                        Text('x${day * 100}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        if (isClaimed) const Icon(Icons.check_circle, color: AppColors.green)
                        else if (isCurrent)
                          ElevatedButton(
                            onPressed: () {
                              setState(() => currentDay++);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Claimed!')));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(horizontal: 12)),
                            child: const Text('CLAIM', style: TextStyle(fontSize: 12)),
                          )
                        else
                          const Text('Locked', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
