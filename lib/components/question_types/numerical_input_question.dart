import 'package:flutter/material.dart';

class NumericalInputQuestion extends StatefulWidget {
  final String questionText;
  final String? userAnswer; // store as string, convert as needed
  final ValueChanged<String> onAnswerChanged;

  const NumericalInputQuestion({
    Key? key,
    required this.questionText,
    this.userAnswer,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  State<NumericalInputQuestion> createState() => _NumericalInputQuestionState();
}

class _NumericalInputQuestionState extends State<NumericalInputQuestion> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userAnswer ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.questionText,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter your answer',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onAnswerChanged(value);
          },
        ),
      ],
    );
  }
}
