import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final int? selectedOption;
  final ValueChanged<int?> onAnswerChanged;

  const MultipleChoiceQuestion({
    Key? key,
    required this.questionText,
    required this.options,
    required this.selectedOption,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Column(
          children: options.asMap().entries.map((entry) {
            final idx = entry.key;
            final optionText = entry.value;
            return RadioListTile<int>(
              title: Text(optionText),
              value: idx,
              groupValue: selectedOption,
              onChanged: (value) => onAnswerChanged(value),
            );
          }).toList(),
        )
      ],
    );
  }
}
