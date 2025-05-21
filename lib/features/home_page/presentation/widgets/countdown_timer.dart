import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
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
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  void _startTimer() {
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;
    // İlk tick: bir sonraki dakika başında
    _timer = Timer(Duration(seconds: secondsToNextMinute), () {
      _updateTime();
      // Sonraki tickler: her dakika başında
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateTime();
      });
    });
  }

  void _updateTime() {
    setState(() {
      _remainingTime = widget.endTime.difference(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.isCompetitionEnded
          ? 'Oyun Sona Erdi'
          : _formatDuration(_remainingTime),
      style: TextStyle(
        color: widget.isCompetitionEnded
            ? Colors.grey
            : (widget.color ?? const Color(0xFF5FC9BF)),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.abs());
    final minutes = twoDigits(duration.inMinutes.remainder(60).abs());
    return '$hours:$minutes';
  }
}
