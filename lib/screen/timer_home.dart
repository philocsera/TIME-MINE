import 'package:timemine/core/core.dart';
import 'package:drift/drift.dart' show Value;


class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> {
  final List<String> titles = ['Youtube', 'Novel'];
  final TaskChunk nowTask = TaskChunk();
  bool mode = true;
  bool timerStarted = false;
  String nowTaskname = '';

  void modeChanged(bool nowMode){
    setState(() => mode = nowMode);
  }

  Future<void> onPlayButtonPressed() async {
    final db = context.read<AppDB>();

    if (timerStarted) {
      nowTask.setEndAt(DateTime.now());

      await db.insertSession(SessionsCompanion.insert(
        taskName: nowTask.taskName,
        startAt: nowTask.startAt,
        endAt: nowTask.endAt,
        mode: Value(mode),
      ));

      setState(() { 
        timerStarted = false; 
        nowTaskname = '';
      });
      return;
    }

    if (nowTaskname.trim().isEmpty) {
      final picked = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => TitlePickerPage(
            mode: mode,
            titles: titles,
            initialSelected: null,
          ),
        ),
      );

      if (picked == null || picked.trim().isEmpty) return;

      setState(() => nowTaskname = picked);
    }

    nowTask.setTaskName(nowTaskname);
    nowTask.setStartAt(DateTime.now());

    setState(() => timerStarted = true);
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
            const Spacer(flex: 15),
            // Expanded(flex: 10, child: Taskname(mode: mode, titles:titles, onNameChanged: onChangedName)),
            const Spacer(flex: 10),
            Expanded(flex: 55, child: PlayButton(mode: mode, timerStarted: timerStarted, onPressed: onPlayButtonPressed)),
            const Spacer(flex: 5),
            Expanded(flex: 5, child: ModeSelector(mode: mode, modeChanged: modeChanged)),
            const Spacer(flex: 10),
          ]
          else ...[
            const Spacer(flex: 15),
            Expanded(flex: 10, child: Text(nowTaskname, style: const TextStyle(color: Colors.white, fontSize: 48)) ),
            Expanded(flex: 55, child: PlayButton(mode: mode, timerStarted: timerStarted,onPressed: onPlayButtonPressed)),
            Expanded(flex: 15, child: TimerWidget()),
            const Spacer(flex: 5),
          ],
        ],
      ),
    );
  }
}