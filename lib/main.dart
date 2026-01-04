import 'package:flutter/material.dart';
import 'widgets/TaskName.dart';

void main() {
  runApp(const TimeChunk());
}

class TimeChunk extends StatelessWidget {
  const TimeChunk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TimerHome(),
    );
  }
}

class TimerHome extends StatelessWidget {
  const TimerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Taskname(),
    );
  }
}