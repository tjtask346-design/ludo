import 'dart:math';

class SnakesLaddersEngine {
  final int playerCount;
  List<int> positions = [];
  int currentTurn = 0;
  int diceValue = 0;
  bool hasRolled = false;
  bool gameOver = false;
  int winner = -1;
  final Random _random = Random();

  // Classic Snakes & Ladders mappings
  static const Map<int, int> ladders = {
    1: 38, 4: 14, 9: 31, 21: 42, 28: 84, 36: 44, 51: 67, 71: 91, 80: 100
  };
  static const Map<int, int> snakes = {
    16: 6, 47: 26, 49: 11, 56: 53, 62: 19, 64: 60, 87: 24, 93: 73, 95: 75, 98: 78
  };

  SnakesLaddersEngine({required this.playerCount}) {
    positions = List.generate(playerCount, (_) => 0);
  }

  void rollDice() {
    if (hasRolled || gameOver) return;
    diceValue = _random.nextInt(6) + 1;
    hasRolled = true;

    int newPos = positions[currentTurn] + diceValue;
    if (newPos <= 100) {
      positions[currentTurn] = newPos;
      if (ladders.containsKey(newPos)) {
        positions[currentTurn] = ladders[newPos]!;
      } else if (snakes.containsKey(newPos)) {
        positions[currentTurn] = snakes[newPos]!;
      }
    }

    if (positions[currentTurn] == 100) {
      gameOver = true;
      winner = currentTurn;
      return;
    }

    if (diceValue != 6) {
      nextTurn();
    }
  }

  void nextTurn() {
    hasRolled = false;
    diceValue = 0;
    currentTurn = (currentTurn + 1) % playerCount;
  }
}
