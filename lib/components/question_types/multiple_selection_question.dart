import 'package:flutter/material.dart';

class MultipleSelectionQuestion extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final Set<int> selectedOptions; 
  final ValueChanged<Set<int>> onAnswerChanged;

  const MultipleSelectionQuestion({
    Key? key,
    required this.questionText,
    required this.options,
    required this.selectedOptions,
    required this.onAnswerChanged,
  }) : super(key: key);

  void _toggleOption(int idx, bool checked) {
    final newSelected = Set<int>.from(selectedOptions);
    if (checked) {
      newSelected.add(idx);
    } else {
      newSelected.remove(idx);
    }
    onAnswerChanged(newSelected);
  }

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
            final isSelected = selectedOptions.contains(idx);

            return CheckboxListTile(
              title: Text(optionText),
              value: isSelected,
              onChanged: (checked) => _toggleOption(idx, checked ?? false),
            );
          }).toList(),
        ),
      ],
    );
  }
}
