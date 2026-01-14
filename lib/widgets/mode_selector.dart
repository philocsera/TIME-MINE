import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ModeSelector extends StatefulWidget {
  const ModeSelector({super.key, required this.mode, required this.modeChanged});

  final bool mode;
  final Function(bool) modeChanged;

  @override
  State<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 20, child: Image.asset('assets/sword.png', color: widget.mode ? Colors.red : Colors.white)),
          Spacer(flex: 5),
          Expanded(flex: 50, child: AnimatedToggleSwitch<bool>.dual(
            current: widget.mode,
            first: true,
            second: false,
            spacing: 30.0,  // 토글 간 간격r

            // 기본 스타일
            style: const ToggleStyle(
              backgroundColor: Colors.transparent, // 전체 배경
              indicatorBorder: Border.fromBorderSide(BorderSide(color: Colors.white)),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),

            // 선택 상태별 스타일 변경 가능
            styleBuilder: (bool value) {
              return ToggleStyle(
                indicatorColor: Colors.white,
              );
            },

            // 왼/오 토글에 아이콘 넣기

            onChanged: (value) => widget.modeChanged(value),
          )),
          Spacer(flex: 5),
          Expanded(flex: 20, child: Image.asset('assets/shield.png', color: !widget.mode ? Color(0xFF3B82F6) : Colors.white)),
        ],
      ),
    );
  }
}

