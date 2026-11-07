import 'package:flutter/material.dart';
import '../game/ludo_engine.dart';

class LudoBoard extends StatelessWidget {
  final LudoEngine engine;
  final void Function(int tokenIndex)? onTokenTap;

  const LudoBoard({super.key, required this.engine, this.onTokenTap});

  static final List<List<int>> pathCells = [
    [6,1],[6,2],[6,3],[6,4],[6,5],[5,6],[4,6],[3,6],[2,6],[1,6],[0,6],[0,7],
    [0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,9],[6,10],[6,11],[6,12],[6,13],[6,14],[7,14],
    [8,14],[8,13],[8,12],[8,11],[8,10],[8,9],[9,8],[10,8],[11,8],[12,8],[13,8],[14,8],[14,7],
    [14,6],[13,6],[12,6],[11,6],[10,6],[9,6],[8,5],[8,4],[8,3],[8,2],[8,1],[8,0],[7,0],[6,0]
  ];
  static const startIndex = {'red': 0, 'green': 13, 'yellow': 26, 'blue': 39};
  static const safeIndices = {0, 8, 13, 21, 26, 34, 39, 47};
  static const basePositions = {
    'red': [[1,1],[1,4],[4,1],[4,4]], 'green': [[1,10],[1,13],[4,10],[4,13]],
    'yellow': [[10,10],[10,13],[13,10],[13,13]], 'blue': [[10,1],[10,4],[13,1],[13,4]],
  };
  static const homeCells = {
    'red': [[7,1],[7,2],[7,3],[7,4],[7,5]], 'green': [[1,7],[2,7],[3,7],[4,7],[5,7]],
    'yellow': [[7,13],[7,12],[7,11],[7,10],[7,9]], 'blue': [[13,7],[12,7],[11,7],[10,7],[9,7]],
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        final size = constraints.maxWidth;
        final cell = size / 15;
        return Stack(children: [
          CustomPaint(size: Size(size, size), painter: _BoardPainter()),
          ..._buildTokens(cell),
        ]);
      }),
    );
  }

  List<Widget> _buildTokens(double cell) {
    final widgets = <Widget>[];
    for (int p = 0; p < engine.players.length; p++) {
      final player = engine.players[p];
      for (int i = 0; i < 4; i++) {
        final token = player.tokens[i];
        final grid = _posToGrid(player.color, i, token.position);
        
        // Check if this token can be moved
        bool canMove = false;
        if (engine.currentTurnIndex == p && engine.hasRolled && engine.isValidMove(player, i, engine.diceValue)) {
          canMove = true;
        }

        widgets.add(AnimatedPositioned(
          key: ValueKey('${player.color}_$i'),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: grid[1] * cell + cell * 0.1,
          top: grid[0] * cell + cell * 0.1,
          width: cell * 0.8,
          height: cell * 0.8,
          child: GestureDetector(
            onTap: canMove && onTokenTap != null ? () => onTokenTap!(i) : null,
            child: _Token(color: _colorOf(player.color), highlighted: canMove),
          ),
        ));
      }
    }
    return widgets;
  }

  List<int> _posToGrid(String color, int tokenIdx, int pos) {
    if (pos == -1) return basePositions[color]![tokenIdx];
    if (pos <= 50) return pathCells[(startIndex[color]! + pos) % 52];
    if (pos <= 55) return homeCells[color]![pos - 51];
    return homeCells[color]![4];
  }

  Color _colorOf(String name) {
    switch (name) {
      case 'red': return const Color(0xFFE53935);
      case 'green': return const Color(0xFF20A65A);
      case 'yellow': return const Color(0xFFFFC928);
      case 'blue': return const Color(0xFF2878DB);
      default: return Colors.grey;
    }
  }
}

class _Token extends StatelessWidget {
  final Color color;
  final bool highlighted;
  const _Token({required this.color, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: highlighted ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [color.withValues(alpha: 0.8), color], center: const Alignment(-0.4, -0.4)),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: highlighted ? 10 : 4, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    _drawBase(canvas, cell, 9, 0, const Color(0xFFE53935)); // Red
    _drawBase(canvas, cell, 0, 0, const Color(0xFF20A65A)); // Green
    _drawBase(canvas, cell, 0, 9, const Color(0xFFFFC928)); // Yellow
    _drawBase(canvas, cell, 9, 9, const Color(0xFF2878DB)); // Blue

    for (final c in LudoBoard.pathCells) {
      _drawCell(canvas, cell, c[0], c[1], Colors.white, stroke);
    }

    // Home Lanes
    for (int i = 0; i < 5; i++) {
      _drawCell(canvas, cell, 7, 1 + i, const Color(0xFFE53935), stroke);
      _drawCell(canvas, cell, 1 + i, 7, const Color(0xFF20A65A), stroke);
      _drawCell(canvas, cell, 7, 13 - i, const Color(0xFFFFC928), stroke);
      _drawCell(canvas, cell, 13 - i, 7, const Color(0xFF2878DB), stroke);
    }

    _drawCenter(canvas, cell);

    // Safe Stars
    final starPaint = Paint()..color = Colors.grey.shade400;
    for (final idx in LudoBoard.safeIndices) {
      final c = LudoBoard.pathCells[idx];
      final cx = c[1] * cell + cell / 2;
      final cy = c[0] * cell + cell / 2;
      canvas.drawCircle(Offset(cx, cy), cell * 0.2, starPaint);
    }
  }

  void _drawBase(Canvas canvas, double cell, int row, int col, Color color) {
    final rect = Rect.fromLTWH(col * cell, row * cell, cell * 6, cell * 6);
    canvas.drawRect(rect, Paint()..color = color);
    final inner = Rect.fromLTWH((col + 1) * cell, (row + 1) * cell, cell * 4, cell * 4);
    canvas.drawRect(inner, Paint()..color = Colors.white);
    final innerStroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawRect(inner, innerStroke);
  }

  void _drawCell(Canvas canvas, double cell, int row, int col, Color fill, Paint border) {
    final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
    canvas.drawRect(rect, Paint()..color = fill);
    canvas.drawRect(rect, border);
  }

  void _drawCenter(Canvas canvas, double cell) {
    final cx = 7.5 * cell; final cy = 7.5 * cell; final r = 1.5 * cell;
    final triangles = [
      [Offset(cx, cy - r), Offset(cx - r, cy), Offset(cx + r, cy), const Color(0xFF20A65A)], // Green
      [Offset(cx + r, cy), Offset(cx, cy - r), Offset(cx, cy + r), const Color(0xFFFFC928)], // Yellow
      [Offset(cx, cy + r), Offset(cx + r, cy), Offset(cx - r, cy), const Color(0xFF2878DB)], // Blue
      [Offset(cx - r, cy), Offset(cx, cy + r), Offset(cx, cy - r), const Color(0xFFE53935)], // Red
    ];
    for (final t in triangles) {
      final p = Path()..moveTo((t[0] as Offset).dx, (t[0] as Offset).dy)..lineTo((t[1] as Offset).dx, (t[1] as Offset).dy)..lineTo((t[2] as Offset).dx, (t[2] as Offset).dy)..close();
      canvas.drawPath(p, Paint()..color = t[3] as Color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
