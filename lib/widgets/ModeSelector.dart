import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ModeSelector extends StatefulWidget {
  const ModeSelector({super.key});

  @override
  State<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector> {
  bool ModeState = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<bool>.dual(
      current: ModeState,
      first: true,
      second: false,
      spacing: 30.0,  // 토글 간 간격

      // 기본 스타일
      style: const ToggleStyle(
        backgroundColor: Colors.transparent, // 전체 배경
        indicatorBorder: Border.fromBorderSide(BorderSide(color: Colors.white)),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),

      // 선택 상태별 스타일 변경 가능
      styleBuilder: (bool value) {
        return ToggleStyle(
          indicatorColor: value ? Colors.red : Colors.blue,
        );
      },

      // 왼/오 토글에 아이콘 넣기
      iconBuilder: (bool value) {
        return Image.asset(
          value ? 'assets/sword.png' : 'assets/shield.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        );
      },

      onChanged: (value) => setState(() => ModeState = value),
    );
  }
}
