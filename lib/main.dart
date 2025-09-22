import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  bool isXTurn = true;
  String? winner;
  List<int> winningIndices = [];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  void _handleTap(int index) {
    if (board[index] != "" || winner != null) return;

    _controller.forward().then((_) => _controller.reverse());

    setState(() {
      board[index] = isXTurn ? "X" : "O";
      if (_checkWinner(board[index])) {
        winner = board[index];
      } else if (!board.contains("")) {
        winner = "Draw";
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
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isXTurn = true;
      winner = null;
      winningIndices.clear();
    });
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
            Text(
              winner == null
                  ? (isXTurn ? "Red's Turn (X)" : "Blue's Turn (O)")
                  : (winner == "Draw"
                      ? "It's a Draw!"
                      : "${winner == "X" ? "Red" : "Blue"} Wins!"),
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    bool isWinningCell = winningIndices.contains(index);
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.white,
                            boxShadow: isWinningCell
                                ? [
                                    BoxShadow(
                                        color: Colors.yellow.shade400,
                                        blurRadius: 15,
                                        spreadRadius: 2)
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: _buildSymbol(board[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (winner != null)
              AnimatedOpacity(
                opacity: winner != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: _resetGame,
                  child: const Text(
                    "Play Again",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbol(String value) {
    if (value == "X") {
      return Icon(Icons.close, size: 60, color: Colors.red.shade700);
    } else if (value == "O") {
      return Icon(Icons.circle_outlined, size: 60, color: Colors.blue.shade700);
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
