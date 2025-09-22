import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

// -------------------- App Entry --------------------
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
      home: const MainMenu(),
    );
  }
}

// -------------------- Main Menu --------------------
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                children: [
                  TextSpan(
                    text: "Tic-",
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  TextSpan(
                    text: "Tac-",
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  TextSpan(
                    text: "Toe",
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // New Game Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                "New Game",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Game Screen --------------------
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  List<String> board = List.filled(9, "");
  bool isXTurn = true; // X starts first
  String? winner;
  List<int> winningCombination = [];

  int redScore = 0;
  int blueScore = 0;

  // -------------------- Handle Tap --------------------
  void _handleTap(int index) {
    if (board[index] != "" || winner != null) return;

    setState(() {
      board[index] = isXTurn ? "X" : "O";
      List<int>? combo = _checkWinner(board[index]);
      if (combo != null) {
        winner = board[index];
        winningCombination = combo;
        if (winner == "X") {
          redScore++;
        } else {
          blueScore++;
        }
      } else if (!board.contains("")) {
        winner = "Draw";
      } else {
        isXTurn = !isXTurn;
      }
    });
  }

  // -------------------- Check Winner --------------------
  List<int>? _checkWinner(String player) {
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
        return pattern;
      }
    }
    return null;
  }

  // -------------------- Reset Game --------------------
  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isXTurn = true;
      winner = null;
      winningCombination = [];
    });
  }

  // -------------------- Build Symbol --------------------
  Widget _buildSymbol(int index) {
    String value = board[index];
    bool isWinningCell = winningCombination.contains(index);

    if (value == "X") {
      return Icon(
        Icons.close,
        size: 60,
        color: isWinningCell ? Colors.red.shade900 : Colors.red.shade700,
      );
    } else if (value == "O") {
      return Icon(
        Icons.circle_outlined,
        size: 60,
        color: isWinningCell ? Colors.blue.shade900 : Colors.blue.shade700,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isXTurn ? Colors.red.shade300 : Colors.blue.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Turn or Winner Text
            Text(
              winner == null
                  ? (isXTurn ? "Red's Turn (X)" : "Blue's Turn (O)")
                  : (winner == "Draw"
                      ? "It's a Draw!"
                      : "${winner == "X" ? "Red" : "Blue"} Wins!"),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Scoreboard
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreCard("Red (X)", redScore, Colors.red.shade700),
                const SizedBox(width: 30),
                _scoreCard("Blue (O)", blueScore, Colors.blue.shade700),
              ],
            ),
            const SizedBox(height: 40),
            // Game Board
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: _buildSymbol(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Play Again Button
            if (winner != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: _resetGame,
                child: const Text(
                  "Play Again",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
          ],
        ),
      ),
    );
  }

  // -------------------- Score Card --------------------
  Widget _scoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 5),
        Text(score.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
