import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {'title': 'Classic Fun,\nAnytime!', 'desc': 'Play the traditional Ludo game with a modern twist.', 'icon': Icons.grid_on, 'color': AppColors.red},
    {'title': 'Play With\nFriends!', 'desc': 'Create private rooms and challenge your friends online.', 'icon': Icons.people, 'color': AppColors.blue},
    {'title': 'Roll, Win &\nEarn Rewards!', 'desc': 'Complete missions, level up, and unlock amazing rewards.', 'icon': Icons.emoji_events, 'color': AppColors.yellow},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                child: const Text('SKIP', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (val) => setState(() => _currentPage = val),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page['icon'], size: 100, color: page['color']),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['desc'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) => _buildDot(index)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _pages[_currentPage]['color']),
                  child: Text(_currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? _pages[_currentPage]['color'] : AppColors.border,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
