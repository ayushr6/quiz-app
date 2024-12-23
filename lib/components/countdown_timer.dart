import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final Duration totalTime;
  final VoidCallback onTimeUp;

  const CountdownTimer({
    Key? key,
    required this.totalTime,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remainingTime;
  Timer? quizTimer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.totalTime;
    _startTimer();
  }

  @override
  void dispose() {
    quizTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds <= 1) {
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          remainingTime = remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(remainingTime),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
