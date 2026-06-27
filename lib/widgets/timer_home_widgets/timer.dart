import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
    required this.startAt,
    this.running = true,
  });

  /// 타이머 시작 시각 (필수)
  final DateTime startAt;

  /// 실행 중 여부 (정지 상태면 화면 갱신 중단)
  final bool running;

  @override
  State<TimerWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.running) _startTicker();
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // running on/off 처리
    if (!oldWidget.running && widget.running) {
      _startTicker();
    } else if (oldWidget.running && !widget.running) {
      _stopTicker();
    }

    // startAt이 바뀌면 즉시 화면 반영
    if (oldWidget.startAt != widget.startAt && mounted) {
      setState(() {});
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {}); // 매초 repaint만
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startAt);
    final seconds = elapsed.isNegative ? 0 : elapsed.inSeconds;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatHMS(seconds),
          style: const TextStyle(fontSize: 48, color: Colors.white),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// HH:MM:SS (MM 0~59 정상 처리)
  String _formatHMS(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}
