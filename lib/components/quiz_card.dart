import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final String quizName;
  final int numberOfQuestions;
  final String difficultyLevel;
  final int? bestScore; // Nullable best score
  final VoidCallback onTap; // Added onTap for navigation

  const QuizCard({
    Key? key,
    required this.quizName,
    required this.numberOfQuestions,
    required this.difficultyLevel,
    this.bestScore,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on difficulty
    Color difficultyColor;
    switch (difficultyLevel.toLowerCase()) {
      case "easy":
        difficultyColor = Colors.green[200]!;
        break;
      case "medium":
        difficultyColor = Colors.orange[200]!;
        break;
      case "hard":
        difficultyColor = Colors.red[200]!;
        break;
      default:
        difficultyColor = Colors.blue[200]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.all(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Quiz Name
              Text(
                quizName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),

              // Number of Questions and Difficulty in one row
              Row(
                children: [
                  Text(
                    'Q: $numberOfQuestions',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      difficultyLevel,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Best Score
              Text(
                bestScore != null
                    ? 'Score: $bestScore/$numberOfQuestions'
                    : "No Attempts",
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Score Bar
              if (bestScore != null) _buildScoreBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(BuildContext context) {
    final double fraction = (bestScore ?? 0) / numberOfQuestions;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        widthFactor: fraction.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
