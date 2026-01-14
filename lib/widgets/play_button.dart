import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({
    super.key,
    required this.mode,
    required this.timerStarted,
    required this.onPressed,
  });

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
  void initState() {
    super.initState();
    _controller = WidgetStatesController()..addListener(_handleStatesChanged);
  }

  void _handleStatesChanged() {
    final isNowPressed = _controller.value.contains(WidgetState.pressed);
    if (isNowPressed != _pressed) {
      setState(() => _pressed = isNowPressed);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStatesChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.mode ? Colors.red : const Color(0xFF3B82F6);
    final String assetPath =
        widget.mode ? 'assets/sword.png' : 'assets/shield.png';

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
          fixedSize: const Size(250, 250),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Transform.scale(
          scale: _pressed ? 0.9 : 1.0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

              final scaleTween = Tween<double>(begin: 0.92, end: 1.0);

              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scaleTween.animate(fade),
                  child: child,
                ),
              );
            },
            child: FittedBox(
              key: ValueKey<bool>(widget.mode),
              fit: BoxFit.contain,
              child: Image.asset(
                assetPath,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
