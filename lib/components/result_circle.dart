import 'package:flutter/material.dart';

class ResultCircle extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ResultCircle({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreText = "$correctAnswers/$totalQuestions";

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
      ),
      child: Center(
        child: Text(
          scoreText,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    // Show a different gradient based on performance
    double percentage = correctAnswers / totalQuestions;
    if (percentage >= 0.8) {
      // Excellent (Greenish gradient)
      return [Colors.greenAccent.shade200, Colors.green.shade400];
    } else if (percentage >= 0.5) {
      // Fair (Bluish gradient)
      return [Colors.lightBlue.shade200, Colors.blue.shade400];
    } else {
      // Needs Improvement (Reddish gradient)
      return [Colors.redAccent.shade200, Colors.red.shade400];
    }
  }
}
