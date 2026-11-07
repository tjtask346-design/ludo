import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final bool rolling;
  final VoidCallback? onTap;

  const DiceWidget({super.key, required this.value, this.rolling = false, this.onTap});

  static const pipPositions = {
    1: [[1,1]], 2: [[0,0],[2,2]], 3: [[0,0],[1,1],[2,2]],
    4: [[0,0],[0,2],[2,0],[2,2]], 5: [[0,0],[0,2],[1,1],[2,0],[2,2]],
    6: [[0,0],[0,2],[1,0],[1,2],[2,0],[2,2]],
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedRotation(
        turns: rolling ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          width: 80, height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.white, Color(0xFFE0E0E0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 6))],
          ),
          child: value == 0
              ? const Center(child: Text('?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54)))
              : GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9, (i) {
                    final row = i ~/ 3; final col = i % 3;
                    final has = (pipPositions[value] ?? []).any((p) => p[0] == row && p[1] == col);
                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: has ? Container(decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle)) : const SizedBox(),
                    );
                  }),
                ),
        ),
      ),
    );
  }
}
