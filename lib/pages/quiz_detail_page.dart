import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/user_provider.dart';
import 'dart:convert';
import 'result_page.dart';
import '../components/countdown_timer.dart';
import '../components/question_types/multiple_choice_question.dart';
import '../components/question_types/multiple_selection_question.dart';
import '../components/question_types/numerical_input_question.dart';

class QuizDetailPage extends StatefulWidget {
  final String quizId;
  final String quizName;
  final int numberOfQuestions;
  final String difficultyLevel;
  final List<Map<String, dynamic>> questions;
  final double bestScore;

  const QuizDetailPage({
    Key? key,
    required this.quizId,
    required this.quizName,
    required this.numberOfQuestions,
    required this.difficultyLevel,
    required this.questions,
    required this.bestScore,
  }) : super(key: key);

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int currentQuestionIndex = 0;
  final Map<int, dynamic> userAnswers = {};
  bool isSubmitting = false;

  void _submitQuiz() async {
    final totalQuestions = widget.questions.length;
    int correctAnswers = 0;

    // Calculate score
    for (int i = 0; i < totalQuestions; i++) {
      final question = widget.questions[i];
      final correctAnswersList =
          (question['correctAnswers'] as List<dynamic>).cast<int>();

      if (question['type'] == 'multiple_choice') {
        if (userAnswers[i] != null &&
            correctAnswersList.contains(userAnswers[i])) {
          correctAnswers++;
        }
      } else if (question['type'] == 'multiple_selection') {
        if (userAnswers[i] != null &&
            Set<int>.from(userAnswers[i])
                .difference(Set<int>.from(correctAnswersList))
                .isEmpty) {
          correctAnswers++;
        }
      } else if (question['type'] == 'numerical_input') {
        if (userAnswers[i] != null &&
            correctAnswersList.contains(int.parse(userAnswers[i]))) {
          correctAnswers++;
        }
      }
    }

    final score = correctAnswers;

    setState(() {
      isSubmitting = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      final response = await http.post(
        Uri.parse('http://localhost:5000/attempt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quizId': widget.quizId,
          'userId': userId,
          'score': score,
          'totalQuestions': totalQuestions,
          'dateTaken': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              correctAnswers: correctAnswers,
              totalQuestions: widget.numberOfQuestions,
              quizId: widget.quizId,
              quizName: widget.quizName,
              numberOfQuestions: widget.numberOfQuestions,
              difficultyLevel: widget.difficultyLevel,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save quiz attempt.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server.')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    final totalQuestions = widget.questions.length;
    final progress = (currentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.quizName),
            CountdownTimer(
              totalTime: Duration(seconds: widget.numberOfQuestions * 30),
              onTimeUp: _submitQuiz,
            ),
          ],
        ),
      ),
      body: isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  Text(
                      'Question ${currentQuestionIndex + 1} of $totalQuestions'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildQuestionUI(currentQuestion),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed:
                            currentQuestionIndex > 0 ? _prevQuestion : null,
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: currentQuestionIndex < totalQuestions - 1
                            ? _nextQuestion
                            : _submitQuiz,
                        child: Text(
                          currentQuestionIndex < totalQuestions - 1
                              ? 'Next'
                              : 'Submit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionUI(Map<String, dynamic> question) {
    final questionType = question['type'];

    switch (questionType) {
      case 'multiple_choice':
        final options = (question['options'] as List<dynamic>).cast<String>();
        return MultipleChoiceQuestion(
          questionText: question['questionText'],
          options: options,
          selectedOption: userAnswers[currentQuestionIndex],
          onAnswerChanged: (value) {
            setState(() {
              userAnswers[currentQuestionIndex] = value;
            });
          },
        );
      case 'numerical_input':
        return NumericalInputQuestion(
          questionText: question['questionText'],
          userAnswer: userAnswers[currentQuestionIndex]?.toString(),
          onAnswerChanged: (value) {
            setState(() {
              userAnswers[currentQuestionIndex] = value;
            });
          },
        );
      case 'multiple_selection':
        final options = (question['options'] as List<dynamic>).cast<String>();
        return MultipleSelectionQuestion(
          questionText: question['questionText'],
          options: options,
          selectedOptions:
              (userAnswers[currentQuestionIndex] as Set<int>?) ?? {},
          onAnswerChanged: (newSelection) {
            setState(() {
              userAnswers[currentQuestionIndex] = newSelection;
            });
          },
        );
      default:
        return const Text('Unsupported question type.');
    }
  }

  void _nextQuestion() {
    setState(() {
      currentQuestionIndex++;
    });
  }

  void _prevQuestion() {
    setState(() {
      currentQuestionIndex--;
    });
  }
}
