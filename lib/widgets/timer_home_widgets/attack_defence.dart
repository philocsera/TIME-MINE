import 'package:flutter/material.dart';
import 'package:timemine/core/classes/attack_defense_time.dart';
import 'package:timemine/widgets/timer_home_widgets/set_time_button.dart';

class AttackDefence extends StatefulWidget {
  const AttackDefence({super.key, required this.ADTime});

  final AttackDefenseTime ADTime;

  @override
  State<AttackDefence> createState() => _AttackDefenceState();
}

class _AttackDefenceState extends State<AttackDefence> {

  void timeSetCompleted(bool AD, Duration newTime){
    setState(() {});
    widget.ADTime.timeChanged(newTime, AD);
  }

  @override
  Widget build(BuildContext context) {
    
    String pad2(int n) => n.toString().padLeft(2, '0');

    return Column(
        children: [
          Expanded(
            flex: 4,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(!widget.ADTime.attackTimeSeted) ...[
                    Text("   Attack Time :  ", style: const TextStyle(color: Colors.white, fontSize: 20)),
                    SetTimeButton(mode: true,onChanged: timeSetCompleted),
                  ] else ... [
                    if(widget.ADTime.remainingTime(true) == Duration.zero) ...[
                      Text("   Attack Time :   COMPLETED", style: const TextStyle(color: Colors.red, fontSize: 20)),
                    ] else ...[
                      Text("   Attack Time :   ${pad2(widget.ADTime.remainingTime(true).inHours)} : ${pad2(widget.ADTime.remainingTime(true).inMinutes%60)} : ${pad2(widget.ADTime.remainingTime(true).inSeconds%60)}", style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ],
                ],
              ),
          ),
          Spacer(flex: 2),
          Expanded(
            flex: 4,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(!widget.ADTime.defenseTimeSeted) ...[
                    Text("Defense Time :  ", style: const TextStyle(color: Colors.white, fontSize: 20)),
                    SetTimeButton(mode: false, onChanged: timeSetCompleted),
                  ] else ... [
                    if(widget.ADTime.remainingTime(false) == Duration.zero) ...[
                      Text("   Defense Time :   COMPLETED", style: const TextStyle(color: Colors.red, fontSize: 20)),
                    ] else ...[
                      Text("Defense Time :   ${pad2(widget.ADTime.remainingTime(false).inHours)} : ${pad2(widget.ADTime.remainingTime(false).inMinutes%60)} : ${pad2(widget.ADTime.remainingTime(false).inSeconds%60)}", style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ],
                ]
            ),
          ),
        ],
    );
  }
}