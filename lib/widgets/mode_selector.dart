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
          Expanded(flex: 20, child: Image.asset('assets/sword.png', color: Colors.white)),
          Spacer(flex: 5),
          Expanded(flex: 50, child: AnimatedToggleSwitch<bool>.dual(
            current: widget.mode,
            first: true,
            second: false,
            spacing: 30.0,

            style: const ToggleStyle(
              backgroundColor: Colors.transparent,
              indicatorBorder: Border.fromBorderSide(BorderSide(color: Colors.white)),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),

            styleBuilder: (bool value) {
              return ToggleStyle(
                indicatorColor: Colors.white,
              );
            },


            onChanged: (value) => widget.modeChanged(value),
          )),
          Spacer(flex: 5),
          Expanded(flex: 20, child: Image.asset('assets/shield.png', color: Colors.white)),
        ],
      ),
    );
  }
}

