import 'package:flutter/material.dart';
import 'package:time_chunking/widgets/PlayButton.dart';
import 'package:time_chunking/widgets/Timer.dart';
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

class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> {
  bool mode = true;
  bool timerStarted = false;
  String nowTaskname = '';

  void modeChanged(bool nowMode){
    setState(() => mode = nowMode);
  }

  void onPlayButtonPressed(){
    setState(() => timerStarted = !timerStarted);
    // Handle play button press
  }

  void onChangedName(String newName){
    setState(() => nowTaskname = newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if(!timerStarted) ...[
            const Spacer(flex: 10),
            Expanded(flex: 10, child: Taskname(mode: mode, onNameChanged: onChangedName)),
            Expanded(flex: 55, child: PlayButton(mode: mode, timerStarted: timerStarted, onPressed: onPlayButtonPressed)),
            Expanded(flex: 5, child: ModeSelector(mode: mode, modeChanged: modeChanged)),
            const Spacer(flex: 10),
          ]
          else ...[
            const Spacer(flex: 10),
            Expanded(flex: 10, child: Text(nowTaskname, style: const TextStyle(color: Colors.white, fontSize: 48)) ),
            Expanded(flex: 55, child: PlayButton(mode: mode, timerStarted: timerStarted,onPressed: onPlayButtonPressed)),
            Expanded(flex: 15, child: TimerWidget()),
            const Spacer(flex: 10),
          ],
        ],
      ),
      bottomNavigationBar: timerStarted ? null : Container(
        height: MediaQuery.of(context).size.height * 0.1,
        child: BottomBar(),
      ),
    );
  }
}