import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerWidget>{
  Timer? _timer;
  int _second = 0;

  @override
  void initState(){
    super.initState();
    _start();
  }

  void _start(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_){
      setState(() {
        _second++;
      });
    });
  }

  void _stop(){
    _timer?.cancel();
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children : [
        Text(
          _format(_second),
          style: const TextStyle( fontSize: 48, color: Colors.white ),
        ),
        const SizedBox(height: 20),
      ]
    );
  }

  String _format(int seconds){
    final m = seconds ~/ 60;
    final h = m ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}