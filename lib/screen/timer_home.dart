import 'package:timemine/core/core.dart';
import 'package:provider/provider.dart';

class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> {
  final TaskChunk nowTask = TaskChunk();
  bool mode = true;
  bool timerStarted = false;
  String nowTaskname = '';

  void modeChanged(bool nowMode){
    setState(() => mode = nowMode);
  }

  void onPlayButtonPressed(){
    final db = context.read<AppDB>();
    if(timerStarted){
      nowTask.setEndAt(DateTime.now());

      db.insertSession(SessionsCompanion.insert(
        taskName: nowTask.taskName,
        startAt: nowTask.startAt,
        endAt: nowTask.endAt,
      ));

    } else {
      nowTask.setTaskName(nowTaskname);
      nowTask.setStartAt(DateTime.now());
    }
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
            const Spacer(flex: 25),
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
    );
  }
}