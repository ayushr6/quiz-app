import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_detail_page.dart';

class PastAttemptsPage extends StatelessWidget {
  final List<Map<String, dynamic>> attempts;
  final String quizId;
  final String quizName;
  final int numberOfQuestions;
  final String difficultyLevel;

  const PastAttemptsPage({
    Key? key,
    required this.attempts,
    required this.quizId,
    required this.quizName,
    required this.numberOfQuestions,
    required this.difficultyLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Attempts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: attempts.length,
                itemBuilder: (context, index) {
                  final attempt = attempts[index];
                  return _buildAttemptCard(
                    date: attempt["dateTaken"] != null
                        ? DateTime.parse(attempt["dateTaken"])
                            .toLocal()
                            .toString()
                            .split(' ')[0]
                        : "Unknown Date",
                    score: (attempt["score"] != null &&
                            attempt["totalQuestions"] != null)
                        ? "${attempt["score"]}/${attempt["totalQuestions"]}"
                        : "0/0",
                    timeTaken: attempt["timeTaken"] ?? "Unknown Time",
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _retakeQuiz(context),
              child: const Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retakeQuiz(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch questions from the backend
      final response = await http.get(
        Uri.parse('http://localhost:5000/quiz/$quizId/questions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final questions = (jsonDecode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        Navigator.pop(context); // Close the loading indicator

        // Navigate to QuizDetailPage with fetched questions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailPage(
              quizId: quizId,
              quizName: quizName,
              numberOfQuestions: numberOfQuestions,
              difficultyLevel: difficultyLevel,
              questions: questions,
              bestScore: 0.0, // Reset the best score for retake
            ),
          ),
        );
      } else {
        Navigator.pop(context); // Close the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch questions.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server.')),
      );
    }
  }

  Widget _buildAttemptCard({
    required String date,
    required String score,
    required String timeTaken,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.blueAccent.shade200,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Score: $score",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Time Taken: $timeTaken",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
