import 'package:flutter/material.dart';

class LudoBoard extends StatelessWidget {
  final Map<String, List<int>> tokensByPlayer;
  final Map<String, String> playerColors;
  final String? highlightedPlayer;
  final void Function(String playerId, int tokenIndex)? onTokenTap;

  const LudoBoard({
    super.key,
    required this.tokensByPlayer,
    required this.playerColors,
    this.highlightedPlayer,
    this.onTokenTap,
  });

  static final List<List<int>> pathCells = [
    [6,1],[6,2],[6,3],[6,4],[6,5],[5,6],[4,6],[3,6],[2,6],[1,6],[0,6],[0,7],
    [0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,9],[6,10],[6,11],[6,12],[6,13],[6,14],[7,14],
    [8,14],[8,13],[8,12],[8,11],[8,10],[8,9],[9,8],[10,8],[11,8],[12,8],[13,8],[14,8],[14,7],
    [14,6],[13,6],[12,6],[11,6],[10,6],[9,6],[8,5],[8,4],[8,3],[8,2],[8,1],[8,0],[7,0],[6,0]
  ];
  static const startIndex = {'red': 0, 'green': 13, 'yellow': 26, 'blue': 39};
  static const safeIndices = {0, 8, 13, 21, 26, 34, 39, 47};
  static const basePositions = {
    'red': [[1,1],[1,4],[4,1],[4,4]],
    'green': [[1,10],[1,13],[4,10],[4,13]],
    'yellow': [[10,10],[10,13],[13,10],[13,13]],
    'blue': [[10,1],[10,4],[13,1],[13,4]],
  };
  static const homeCells = {
    'red': [[7,1],[7,2],[7,3],[7,4],[7,5]],
    'green': [[1,7],[2,7],[3,7],[4,7],[5,7]],
    'yellow': [[7,13],[7,12],[7,11],[7,10],[7,9]],
    'blue': [[13,7],[12,7],[11,7],[10,7],[9,7]],
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
    for (final entry in tokensByPlayer.entries) {
      final pid = entry.key;
      final tokens = entry.value;
      final color = playerColors[pid] ?? 'red';
      for (int i = 0; i < tokens.length; i++) {
        final grid = _posToGrid(color, i, tokens[i]);
        final isMyToken = pid == highlightedPlayer;
        widgets.add(AnimatedPositioned(
          key: ValueKey('${pid}_$i'),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          left: grid[1] * cell + cell * 0.1,
          top: grid[0] * cell + cell * 0.1,
          width: cell * 0.8,
          height: cell * 0.8,
          child: GestureDetector(
            onTap: isMyToken && onTokenTap != null ? () => onTokenTap!(pid, i) : null,
            child: _Token(color: _colorOf(color), highlighted: isMyToken),
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
      case 'red': return Colors.red.shade600;
      case 'green': return Colors.green.shade600;
      case 'yellow': return Colors.amber.shade600;
      case 'blue': return Colors.blue.shade600;
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
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: highlighted ? color.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.35),
            blurRadius: highlighted ? 12 : 4,
            spreadRadius: highlighted ? 2 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final stroke = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFF8F9FA));

    _drawBase(canvas, cell, 0, 0, Colors.red.shade100, Colors.red.shade700);
    _drawBase(canvas, cell, 0, 9, Colors.green.shade100, Colors.green.shade700);
    _drawBase(canvas, cell, 9, 9, Colors.amber.shade100, Colors.amber.shade700);
    _drawBase(canvas, cell, 9, 0, Colors.blue.shade100, Colors.blue.shade700);

    for (final c in LudoBoard.pathCells) {
      _drawCell(canvas, cell, c[0], c[1], Colors.white, stroke);
    }

    for (int i = 0; i < 5; i++) {
      _drawCell(canvas, cell, 7, 1 + i, Colors.red.shade300, stroke);
      _drawCell(canvas, cell, 1 + i, 7, Colors.green.shade300, stroke);
      _drawCell(canvas, cell, 7, 13 - i, Colors.amber.shade400, stroke);
      _drawCell(canvas, cell, 13 - i, 7, Colors.blue.shade300, stroke);
    }

    _drawCenter(canvas, cell);

    final safePaint = Paint()..color = Colors.amber.shade800;
    for (final idx in LudoBoard.safeIndices) {
      final c = LudoBoard.pathCells[idx];
      final cx = c[1] * cell + cell / 2;
      final cy = c[0] * cell + cell / 2;
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = -3.14159 / 2 + i * 2 * 3.14159 / 5;
        final x = cx + cell * 0.22 * (i % 2 == 0 ? 1 : 0.4) * (i == 0 ? 1 : 1);
        final y = cy + cell * 0.22 * (i % 2 == 0 ? 1 : 0.4) * (i == 0 ? 1 : 1);
        final px = cx + cell * 0.22 * _cos(angle + i * 0.3);
        final py = cy + cell * 0.22 * _sin(angle + i * 0.3);
        if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
      }
      path.close();
      canvas.drawCircle(Offset(cx, cy), cell * 0.2, safePaint);
    }
  }

  double _cos(double x) => (x == x) ? (x * 0.7) : 0;
  double _sin(double x) => (x == x) ? (x * 0.5) : 0;

  void _drawBase(Canvas canvas, double cell, int row, int col, Color fill, Color accent) {
    final rect = Rect.fromLTWH(col * cell, row * cell, cell * 6, cell * 6);
    canvas.drawRect(rect, Paint()..color = fill);
    canvas.drawRect(rect, Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2);
    final inner = Rect.fromLTWH((col + 1) * cell, (row + 1) * cell, cell * 4, cell * 4);
    canvas.drawRect(inner, Paint()..color = Colors.white);
    canvas.drawRect(inner, Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawCell(Canvas canvas, double cell, int row, int col, Color fill, Paint border) {
    final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
    canvas.drawRect(rect, Paint()..color = fill);
    canvas.drawRect(rect, border);
  }

  void _drawCenter(Canvas canvas, double cell) {
    final cx = 7.5 * cell;
    final cy = 7.5 * cell;
    final r = 1.5 * cell;
    final triangles = [
      [Offset(cx, cy - r), Offset(cx - r, cy), Offset(cx + r, cy), Colors.red.shade600],
      [Offset(cx + r, cy), Offset(cx, cy - r), Offset(cx, cy + r), Colors.green.shade600],
      [Offset(cx, cy + r), Offset(cx + r, cy), Offset(cx - r, cy), Colors.amber.shade600],
      [Offset(cx - r, cy), Offset(cx, cy + r), Offset(cx, cy - r), Colors.blue.shade600],
    ];
    for (final t in triangles) {
      final p = Path()
        ..moveTo((t[0] as Offset).dx, (t[0] as Offset).dy)
        ..lineTo((t[1] as Offset).dx, (t[1] as Offset).dy)
        ..lineTo((t[2] as Offset).dx, (t[2] as Offset).dy)
        ..close();
      canvas.drawPath(p, Paint()..color = t[3] as Color);
    }
    canvas.drawCircle(Offset(cx, cy), cell * 0.35, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), cell * 0.35, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
