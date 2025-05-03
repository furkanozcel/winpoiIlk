import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatelessWidget {
  final DateTime endTime;
  final bool isCompetitionEnded;
  final Color? color;

  const CountdownTimer({
    super.key,
    required this.endTime,
    required this.isCompetitionEnded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final remainingTime = endTime.difference(DateTime.now());
        return Text(
          isCompetitionEnded
              ? 'Oyun Sona Erdi'
              : _formatDuration(remainingTime),
          style: TextStyle(
            color: isCompetitionEnded
                ? Colors.grey
                : (color ?? const Color(0xFF5FC9BF)),
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.abs());
    final minutes = twoDigits(duration.inMinutes.remainder(60).abs());
    final seconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return '$hours:$minutes:$seconds';
  }
}
