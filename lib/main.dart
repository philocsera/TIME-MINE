import 'package:flutter/material.dart';
import 'package:time_chunking/widgets/PlayButton.dart';
import 'widgets/TaskName.dart';
import 'widgets/ModeSelector.dart';
import 'widgets/BottomBar.dart';

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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Taskname(),
          PlayButton(),
          ModeSelector(),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}