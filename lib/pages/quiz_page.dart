import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; 
import '../components/quiz_card.dart';
import 'quiz_detail_page.dart';
import 'past_attempts_page.dart';
import '../providers/user_provider.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuizzesWithScores();
  }

  Future<void> _fetchQuizzesWithScores() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      // Fetch quizzes
      final quizzesResponse = await http.get(
        Uri.parse('http://localhost:5000/quiz'),
        headers: {'Content-Type': 'application/json'},
      );

      if (quizzesResponse.statusCode == 200) {
        final quizzesData = jsonDecode(quizzesResponse.body) as List;

        // Fetch best scores for the user
        List<Map<String, dynamic>> quizzesWithScores = [];
        for (var quiz in quizzesData) {
          final attemptsResponse = await http.get(
            Uri.parse(
                'http://localhost:5000/attempt/${quiz['_id']}/user/$userId'),
            headers: {'Content-Type': 'application/json'},
          );

          int? bestScore;

          if (attemptsResponse.statusCode == 200) {
            final attempts = jsonDecode(attemptsResponse.body) as List;

            if (attempts.isNotEmpty) {
              // Calculate the best score
              bestScore = attempts
                  .map((attempt) => attempt['score'] as int)
                  .reduce((a, b) => a > b ? a : b);
            }
          }

          quizzesWithScores.add({
            "quizId": quiz['_id'],
            "quizName": quiz['name'],
            "numberOfQuestions": quiz['numberOfQuestions'],
            "difficultyLevel": quiz['difficulty'],
            "bestScore": bestScore,
          });
        }

        setState(() {
          quizzes = quizzesWithScores;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch quizzes.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Could not connect to the server.';
        isLoading = false;
      });
    }
  }

  Future<void> _handleQuizTap(
      BuildContext context, Map<String, dynamic> quiz) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/attempt/${quiz['quizId']}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final attempts = (jsonDecode(response.body) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        if (attempts.isEmpty) {
          // No past attempts, fetch questions and navigate to Quiz Page
          final questionsResponse = await http.get(
            Uri.parse('http://localhost:5000/quiz/${quiz['quizId']}/questions'),
            headers: {'Content-Type': 'application/json'},
          );

          if (questionsResponse.statusCode == 200) {
            final questions =
                (jsonDecode(questionsResponse.body) as List<dynamic>)
                    .map((e) => e as Map<String, dynamic>)
                    .toList();

            final shouldRefresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizDetailPage(
                  quizId: quiz['quizId'],
                  quizName: quiz['quizName'],
                  numberOfQuestions: quiz['numberOfQuestions'],
                  difficultyLevel: quiz['difficultyLevel'],
                  questions: (questions as List<dynamic>)
                      .map((e) => e as Map<String, dynamic>)
                      .toList(),
                  bestScore: quiz['bestScore'] ?? 0,
                ),
              ),
            );

            if (shouldRefresh == true) {
              _fetchQuizzesWithScores(); // Refresh quizzes when returning
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch questions.')),
            );
          }
        } else {
          // Show past attempts
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PastAttemptsPage(
                attempts: attempts,
                quizId: quiz['quizId'],
                quizName: quiz['quizName'],
                numberOfQuestions: quiz['numberOfQuestions'],
                difficultyLevel: quiz['difficultyLevel'],
              ),
            ),
          );

          if (shouldRefresh == true) {
            _fetchQuizzesWithScores(); // Refresh the quizzes on QuizPage
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch attempts.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching data.')),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        title: const Text('Questionnaires'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return QuizCard(
              quizName: quiz['quizName'],
              numberOfQuestions: quiz['numberOfQuestions'],
              difficultyLevel: quiz['difficultyLevel'],
              bestScore: quiz['bestScore'],
              onTap: () => _handleQuizTap(context, quiz),
            );
          },
        ),
      ),
    );
  }
}
