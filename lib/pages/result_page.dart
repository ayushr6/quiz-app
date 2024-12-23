import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/components/result_circle.dart';
import 'package:quiz_app/pages/quiz_page.dart';
import 'dart:convert';
import 'past_attempts_page.dart';

class ResultPage extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String quizId; // Pass the quizId to fetch attempts
  final String quizName;
  final int numberOfQuestions;
  final String difficultyLevel;

  const ResultPage({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quizId,
    required this.quizName,
    required this.numberOfQuestions,
    required this.difficultyLevel,
  }) : super(key: key);

  Future<void> _navigateToPastAttempts(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/attempt/$quizId/attempts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final attempts = (jsonDecode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        Navigator.pop(context); // Close loading indicator

        // Navigate to PastAttemptsPage with updated attempts
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PastAttemptsPage(
              attempts: attempts, // Replace the list with the latest data
              quizId: quizId,
              quizName: quizName,
              numberOfQuestions: numberOfQuestions,
              difficultyLevel: difficultyLevel,
            ),
          ),
        );
      } else {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch past attempts.')),
        );
      }
    } catch (error) {
      Navigator.pop(context); // Close loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage = correctAnswers / totalQuestions;
    String message = _getMessage(percentage);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueGrey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Score Circle
                  ResultCircle(
                    correctAnswers: correctAnswers,
                    totalQuestions: totalQuestions,
                  ),
                  const SizedBox(height: 30),
                  // Navigate to Past Attempts Page
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const QuizPage(), // Redirect to QuizPage
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMessage(double percentage) {
    if (percentage >= 0.8) {
      return "Excellent Job!";
    } else if (percentage >= 0.5) {
      return "Good Effort!";
    } else {
      return "Keep Practicing!";
    }
  }
}
