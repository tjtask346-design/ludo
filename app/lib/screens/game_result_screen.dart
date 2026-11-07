import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'main_navigation_screen.dart';

class GameResultScreen extends StatefulWidget {
  final String winnerName;
  final bool isWin;
  const GameResultScreen({super.key, required this.winnerName, this.isWin = true});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Winner Graphic
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.isWin ? AppColors.yellow : AppColors.textLight, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Icon(
                      widget.isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                      size: 100,
                      color: widget.isWin ? AppColors.yellow : AppColors.textLight,
                    ),
                  ),
                  if (widget.isWin)
                    const Icon(Icons.workspace_premium, size: 80, color: AppColors.yellow),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                widget.isWin ? 'VICTORY!' : 'DEFEAT',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: widget.isWin ? AppColors.yellow : AppColors.red,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.winnerName} won the match',
                style: const TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // Rewards
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.yellow, size: 32),
                    const SizedBox(width: 10),
                    Text(widget.isWin ? '+500' : '+50', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Usually we'd route back to game setup
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                        child: const Text('PLAY AGAIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                        child: const Text('GO TO HOME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
