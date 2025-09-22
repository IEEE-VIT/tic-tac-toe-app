import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TicTacToePage(),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage>
    with SingleTickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  bool isXTurn = true;

  String? winner;
  List<int>? winningIndices;
  int redWins = 0;
  int blueWins = 0;

  late AnimationController _controller;
  late Animation<double> _endgameScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _endgameScale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (board[index] != "" || winner != null) return;

    setState(() {
      board[index] = isXTurn ? "X" : "O";
      if (_checkWinner(board[index])) {
        winner = board[index];

        // Update scoreboard
        if (winner == "X") {
          redWins++;
        } else if (winner == "O") {
          blueWins++;
        }

        _controller.forward(from: 0);
      } else if (!board.contains("")) {
        winner = "Draw";
        _controller.forward(from: 0);
      } else {
        isXTurn = !isXTurn;
      }
    });
  }

  bool _checkWinner(String player) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        winningIndices = pattern;
        return true;
      }
    }
    winningIndices = null;
    return false;
  }

  void _resetBoard() {
    setState(() {
      board = List.filled(9, "");
      isXTurn = true;
      winner = null;
      winningIndices = null;
      _controller.reset();
    });
  }

  void _resetScores() {
    setState(() {
      redWins = 0;
      blueWins = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isXTurn ? Colors.red.shade100 : Colors.blue.shade100;
    Color redColor = Colors.red.shade700;
    Color blueColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scoreboard UI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreCard("Red (X)", redWins, redColor),
                    _buildScoreCard("Blue (O)", blueWins, blueColor),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _resetScores,
                      child: const Text(
                        "Reset Scores",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: winner == null
                    ? Text(
                        isXTurn ? "Red's Turn (X)" : "Blue's Turn (O)",
                        key: ValueKey(isXTurn),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isXTurn ? redColor : blueColor,
                        ),
                      )
                    : ScaleTransition(
                        scale: _endgameScale,
                        child: Container(
                          key: ValueKey(winner),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            winner == "Draw"
                                ? "It's a Draw!"
                                : "${winner == "X" ? "Red" : "Blue"} Wins!",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: winner == "Draw"
                                  ? Colors.black87
                                  : winner == "X"
                                      ? redColor
                                      : blueColor,
                              shadows: winner != "Draw"
                                  ? [
                                      Shadow(
                                        color: winner == "X"
                                            ? redColor
                                            : blueColor,
                                        offset: const Offset(2, 2),
                                        blurRadius: 14,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      bool isWinningCell =
                          winningIndices?.contains(index) ?? false;
                      return AnimatedScale(
                        scale: board[index].isNotEmpty ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.elasticOut,
                        child: GestureDetector(
                          onTap: () => _handleTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isWinningCell
                                    ? Colors.yellow.shade800
                                    : Colors.black,
                                width: isWinningCell ? 4.0 : 2.0,
                              ),
                              color: Colors.white,
                              boxShadow: isWinningCell
                                  ? [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.7),
                                        blurRadius: 12,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _buildSymbol(board[index], redColor, blueColor),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _resetBoard,
                child: const Text(
                  "Play Again",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$score",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymbol(String value, Color redColor, Color blueColor) {
    if (value == "X") {
      return Icon(Icons.close, size: 64, color: redColor);
    } else if (value == "O") {
      return Icon(Icons.circle_outlined, size: 64, color: blueColor);
    }
    return const SizedBox.shrink();
  }
}
import 'dart:math';


String currentPlayer = 'X';

void initState() {
  super.initState();
  _setStartingPlayer();
}

void _setStartingPlayer() {
  Random random = Random();
  int randomNumber = random.nextInt(2); 
  if (randomNumber == 0) {
    currentPlayer = 'X';
  } else {
    currentPlayer = 'O';
  }
}

void _resetGame() {
  
  _setStartingPlayer();
  
}
