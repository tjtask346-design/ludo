import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../game/snakes_ladders_engine.dart';
import '../widgets/dice_widget.dart';

class SnakesLaddersScreen extends StatefulWidget {
  final int playerCount;
  const SnakesLaddersScreen({super.key, required this.playerCount});

  @override
  State<SnakesLaddersScreen> createState() => _SnakesLaddersScreenState();
}

class _SnakesLaddersScreenState extends State<SnakesLaddersScreen> {
  late SnakesLaddersEngine engine;
  bool isRolling = false;

  @override
  void initState() {
    super.initState();
    engine = SnakesLaddersEngine(playerCount: widget.playerCount);
  }

  void _rollDice() {
    if (engine.hasRolled || engine.gameOver) return;
    setState(() => isRolling = true);
    HapticFeedback.mediumImpact();
    engine.rollDice();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => isRolling = false);
      if (engine.gameOver) {
        _showWinnerDialog();
      }
    });
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Player ${engine.winner + 1} Wins!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Congratulations!', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('PLAY AGAIN', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('SNAKES & LADDERS')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final size = constraints.maxWidth;
                      return Stack(
                        children: [
                          CustomPaint(size: Size(size, size), painter: _BoardPainter()),
                          ..._buildTokens(size),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player ${engine.currentTurn + 1}\'s Turn', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(engine.hasRolled ? 'Next player...' : 'Tap dice to roll', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                  DiceWidget(value: engine.diceValue, rolling: isRolling, onTap: _rollDice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTokens(double size) {
    final cell = size / 10;
    List<Widget> widgets = [];
    List<Color> colors = [AppColors.red, AppColors.green, AppColors.yellow, AppColors.blue];
    
    for (int i = 0; i < engine.positions.length; i++) {
      int pos = engine.positions[i];
      if (pos == 0) pos = 1; // Start at 1 visually
      
      int row = 9 - ((pos - 1) ~/ 10);
      int col = row % 2 == 0 ? (pos - 1) % 10 : 9 - ((pos - 1) % 10);
      
      double dx = (i % 2) * (cell * 0.2);
      double dy = (i ~/ 2) * (cell * 0.2);

      widgets.add(AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        left: col * cell + cell * 0.15 + dx,
        top: row * cell + cell * 0.15 + dy,
        width: cell * 0.5,
        height: cell * 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: colors[i],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 10;
    final stroke = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = AppColors.card);

    // Draw Grid
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        final rect = Rect.fromLTWH(j * cell, i * cell, cell, cell);
        canvas.drawRect(rect, stroke);
        
        // Draw numbers
        int row = 9 - i;
        int num = row % 2 == 0 ? row * 10 + j + 1 : row * 10 + (10 - j);
        
        final textPainter = TextPainter(
          text: TextSpan(text: '$num', style: TextStyle(color: Colors.white38, fontSize: cell * 0.2)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(j * cell + cell * 0.1, i * cell + cell * 0.1));
      }
    }

    // Draw Snakes and Ladders (Simplified visually)
    final snakePaint = Paint()..color = AppColors.red..style = PaintingStyle.stroke..strokeWidth = cell * 0.15;
    final ladderPaint = Paint()..color = AppColors.green..style = PaintingStyle.stroke..strokeWidth = cell * 0.15;

    SnakesLaddersEngine.ladders.forEach((start, end) {
      _drawLine(canvas, size, start, end, ladderPaint);
    });

    SnakesLaddersEngine.snakes.forEach((start, end) {
      _drawLine(canvas, size, start, end, snakePaint);
    });
  }

  void _drawLine(Canvas canvas, Size size, int start, int end, Paint paint) {
    final cell = size.width / 10;
    
    Offset getPos(int pos) {
      int row = 9 - ((pos - 1) ~/ 10);
      int col = row % 2 == 0 ? (pos - 1) % 10 : 9 - ((pos - 1) % 10);
      return Offset(col * cell + cell / 2, row * cell + cell / 2);
    }

    canvas.drawLine(getPos(start), getPos(end), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
