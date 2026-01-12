import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, required this.mode, required this.timerStarted, required this.onPressed});

  final bool mode;
  final bool timerStarted;
  final VoidCallback onPressed;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  late final WidgetStatesController _controller;
  bool _pressed = false;

  @override
  void initState(){
    super.initState();
    _controller = WidgetStatesController()..addListener(_handleStatesChanged);
  }

  void _handleStatesChanged(){
    final isNowPressed = _controller.value.contains(WidgetState.pressed);
    if (isNowPressed != _pressed){
      setState(() => _pressed = isNowPressed);
    }
  }

  @override
  void dispose(){
    _controller.removeListener(_handleStatesChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Center(
        child: ElevatedButton(
        statesController: _controller,
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          fixedSize: const Size(400, 400), 
        ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
        child: Transform.scale(
          scale: _pressed ? 0.9 : 1.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(!widget.timerStarted ? 'assets/play_button.png' : 'assets/pause_button.png', color: widget.mode ? Colors.red : Colors.blue),
          )
        )
      )
    );
  }
}