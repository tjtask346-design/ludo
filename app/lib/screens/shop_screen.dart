import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('SHOP'),
          bottom: const TabBar(
            labelColor: AppColors.blue,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.blue,
            tabs: [
              Tab(text: 'Dice'),
              Tab(text: 'Tokens'),
              Tab(text: 'Themes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShopGrid(category: 'Dice'),
            _ShopGrid(category: 'Tokens'),
            _ShopGrid(category: 'Themes'),
          ],
        ),
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  final String category;
  const _ShopGrid({required this.category});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        bool isOwned = index == 0;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOwned ? AppColors.green : AppColors.border, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Icon(
                    category == 'Dice' ? Icons.casino : category == 'Tokens' ? Icons.circle : Icons.dashboard,
                    size: 40,
                    color: category == 'Dice' ? AppColors.red : category == 'Tokens' ? AppColors.green : AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('${category} Skin ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (isOwned)
                const Text('OWNED', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold))
              else
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.monetization_on, size: 16, color: AppColors.yellow),
                  label: Text('${(index + 1) * 500}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
