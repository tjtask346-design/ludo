import 'dart:math';

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
  int currentTurnIndex = 0;
  int diceValue = 0;
  bool hasRolled = false;
  bool gameOver = false;
  String winner = "";
  final Random _random = Random();

  LudoEngine({required this.players});

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
    if (pos == 56) return false; // Already home
    if (pos == -1) return dice == 6; // Need 6 to open
    if (pos + dice > 56) return false; // Exact roll needed to finish
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
      // If extra turn, but it's a bot, auto roll after delay
      if (currentPlayer.isBot) _botRoll();
    }
  }

  bool _checkCapture(LudoPlayer player, int tokenIndex) {
    int pos = player.tokens[tokenIndex].position;
    if (pos < 0 || pos > 50) return false;
    
    // Safe squares (based on starting points and star squares)
    List<int> safeSquares = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safeSquares.contains(pos)) return false;

    bool captured = false;
    for (var otherPlayer in players) {
      if (otherPlayer == player) continue;
      for (var otherToken in otherPlayer.tokens) {
        if (otherToken.position == pos) {
          otherToken.position = -1; // Send back to base
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      rollDice();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!hasRolled) return;
        // Bot logic: find first valid move
        for (int i = 0; i < 4; i++) {
          if (isValidMove(currentPlayer, i, diceValue)) {
            moveToken(i);
            break;
          }
        }
      });
    });
  }
}
