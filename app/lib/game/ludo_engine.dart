import 'dart:math';

enum AIDifficulty { easy, medium, hard }

class LudoToken {
  int position; // -1 = Base, 0 to 50 = Track, 51 to 55 = Home Lane, 56 = Home
  LudoToken({this.position = -1});
}

class LudoPlayer {
  final String name;
  final String color;
  final bool isBot;
  final List<LudoToken> tokens = [LudoToken(), LudoToken(), LudoToken(), LudoToken()];
  LudoPlayer({required this.name, required this.color, this.isBot = false});
}

class LudoEngine {
  final List<LudoPlayer> players;
  final AIDifficulty difficulty;
  int currentTurnIndex = 0;
  int diceValue = 0;
  bool hasRolled = false;
  bool gameOver = false;
  String winner = "";
  final Random _random = Random();

  LudoEngine({required this.players, this.difficulty = AIDifficulty.medium});

  LudoPlayer get currentPlayer => players[currentTurnIndex];

  int rollDice() {
    if (hasRolled || gameOver) return diceValue;
    diceValue = _random.nextInt(6) + 1;
    hasRolled = true;
    
    // Check if any valid moves exist
    if (!_hasValidMoves(currentPlayer, diceValue)) {
      Future.delayed(const Duration(milliseconds: 800), () {
        nextTurn();
      });
    }
    return diceValue;
  }

  bool _hasValidMoves(LudoPlayer player, int dice) {
    for (int i = 0; i < 4; i++) {
      if (isValidMove(player, i, dice)) return true;
    }
    return false;
  }

  bool isValidMove(LudoPlayer player, int tokenIndex, int dice) {
    int pos = player.tokens[tokenIndex].position;
    if (pos == 56) return false;
    if (pos == -1) return dice == 6;
    if (pos + dice > 56) return false;
    return true;
  }

  void moveToken(int tokenIndex) {
    if (!hasRolled || gameOver) return;
    LudoPlayer player = currentPlayer;
    if (!isValidMove(player, tokenIndex, diceValue)) return;

    LudoToken token = player.tokens[tokenIndex];
    if (token.position == -1) {
      token.position = 0;
    } else {
      token.position += diceValue;
    }

    bool extraTurn = diceValue == 6;
    bool captured = _checkCapture(player, tokenIndex);

    if (captured) extraTurn = true;
    if (token.position == 56) extraTurn = true;

    if (_checkWin(player)) {
      gameOver = true;
      winner = player.name;
      return;
    }

    hasRolled = false;
    if (!extraTurn) {
      nextTurn();
    } else {
      if (currentPlayer.isBot) _botRoll();
    }
  }

  bool _checkCapture(LudoPlayer player, int tokenIndex) {
    int pos = player.tokens[tokenIndex].position;
    if (pos < 0 || pos > 50) return false;
    
    List<int> safeSquares = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safeSquares.contains(pos)) return false;

    bool captured = false;
    for (var otherPlayer in players) {
      if (otherPlayer == player) continue;
      for (var otherToken in otherPlayer.tokens) {
        if (otherToken.position == pos) {
          otherToken.position = -1;
          captured = true;
        }
      }
    }
    return captured;
  }

  bool _checkWin(LudoPlayer player) {
    for (var token in player.tokens) {
      if (token.position != 56) return false;
    }
    return true;
  }

  void nextTurn() {
    hasRolled = false;
    diceValue = 0;
    currentTurnIndex = (currentTurnIndex + 1) % players.length;
    if (currentPlayer.isBot) _botRoll();
  }

  void _botRoll() {
    Future.delayed(const Duration(milliseconds: 800), () {
      rollDice();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!hasRolled || gameOver) return;
        int bestMove = _getBestMove(currentPlayer, diceValue);
        if (bestMove != -1) {
          moveToken(bestMove);
        }
      });
    });
  }

  int _getBestMove(LudoPlayer player, int dice) {
    List<int> validMoves = [];
    for (int i = 0; i < 4; i++) {
      if (isValidMove(player, i, dice)) validMoves.add(i);
    }
    if (validMoves.isEmpty) return -1;
    if (difficulty == AIDifficulty.easy) return validMoves[_random.nextInt(validMoves.length)];

    int bestScore = -9999;
    int bestMove = validMoves[0];

    for (int move in validMoves) {
      int score = 0;
      int newPos = player.tokens[move].position == -1 ? 0 : player.tokens[move].position + dice;

      // Prioritize capturing
      if (_simulateCapture(player, move, newPos)) score += 1000;
      
      // Prioritize reaching home
      if (newPos == 56) score += 500;
      
      // Prioritize opening from base
      if (player.tokens[move].position == -1) score += 300;
      
      // Prioritize entering home lane
      if (newPos > 50 && newPos < 56) score += 200;

      // Hard mode: Avoid landing near opponent
      if (difficulty == AIDifficulty.hard) {
        if (_isVulnerable(player, newPos)) score -= 400;
        if (newPos > 45) score += 150; // Push towards home
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  bool _simulateCapture(LudoPlayer player, int tokenIndex, int newPos) {
    if (newPos > 50) return false;
    List<int> safe = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safe.contains(newPos)) return false;
    for (var p in players) {
      if (p == player) continue;
      for (var t in p.tokens) {
        if (t.position == newPos) return true;
      }
    }
    return false;
  }

  bool _isVulnerable(LudoPlayer player, int pos) {
    if (pos > 50) return false;
    List<int> safe = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safe.contains(pos)) return false;
    for (var p in players) {
      if (p == player) continue;
      for (var t in p.tokens) {
        int dist = pos - t.position;
        if (dist > 0 && dist <= 6) return true;
      }
    }
    return false;
  }
}
