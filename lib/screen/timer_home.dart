import 'package:timemine/core/core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:timemine/widgets/timer_home_widgets/attack_defence.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => TimerHomeState();
}

// mode : true(attack) / false(defense)
class TimerHomeState extends State<TimerHome> with WidgetsBindingObserver {
  // titles
  late final attackTitles;
  late final defenseTitles;

  // timer/session state
  final TaskChunk nowTask = TaskChunk();
  bool mode = true;
  bool timerStarted = false;
  String nowTaskname = '';

  // prefs keys
  static const _kRunning = 'timer_running';
  static const _kStartAt = 'timer_start_at_ms';
  static const _kTaskName = 'timer_task_name';
  static const _kMode = 'timer_mode';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final db = context.read<AppDB>();

    () async {
      // 1) 타이틀 로드
      attackTitles = await db.loadTitlesForType('attack');
      defenseTitles = await db.loadTitlesForType('defense');

      // 2) 타이머 상태 복원 (완전 종료 후 재실행 포함)
      await _restoreRunningTimerIfAny();

      // 3) ADTime 로드는 Controller 쪽에서 이미 loaded로 관리중이니 여기선 별도 불필요
      if (mounted) setState(() {});
    }();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 포그라운드 복귀 시 화면만 새로고침(표시는 startAt 기준 now-startAt으로 계산됨)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (timerStarted && mounted) setState(() {});
    }
  }

  void modeChanged(bool nowMode) {
    setState(() => mode = nowMode);
    if (timerStarted) {
      // 타이머 실행 중 mode 바뀌면 저장 상태도 갱신(원하면 막아도 됨)
      _persistRunningTimer();
    }
  }

  Future<void> onPlayButtonPressed() async {
    final db = context.read<AppDB>();
    final adTime = context.read<ADTimeController>().value;

    // Attack/Defense time 세팅 확인
    if (!adTime.attackTimeSeted || !adTime.defenseTimeSeted) {
      showConditionAlert(context);
      return;
    }

    // ====== STOP ======
    if (timerStarted) {
      await WakelockPlus.disable();
      nowTask.setEndAt(DateTime.now());

      // 1분 미만 기록 X (duration 기반으로 정확하게)
      if (nowTask.duration >= const Duration(minutes: 1)) {
        await db.insertSession(SessionsCompanion.insert(
          taskName: nowTask.taskName,
          startAt: nowTask.startAt,
          endAt: nowTask.endAt,
          mode: Value(mode),
        ));

        await context.read<ADTimeController>().increment(nowTask.duration, mode);
      }

      // 실행 상태 저장 해제
      await _clearRunningTimer();

      setState(() {
        timerStarted = false;
        nowTaskname = '';
      });
      return;
    } else {
      await WakelockPlus.enable();
    }
      
    // ====== START ======
    // taskName 없으면 picker로 받기 (원래 로직 유지)
    if (nowTaskname.trim().isEmpty) {
      final picked = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => TitlePickerPage(
            mode: mode,
            titles: mode ? attackTitles : defenseTitles,
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

    // 실행 상태 저장 (완전 종료 후에도 복원 가능)
    await _persistRunningTimer();
  }

  void onChangedName(String newName) {
    setState(() => nowTaskname = newName);
    if (timerStarted) {
      _persistRunningTimer();
    }
  }

  void showConditionAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please set both Attack and Defense times before starting the timer.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // -----------------------
  // Persist / Restore logic
  // -----------------------

  Future<void> _persistRunningTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRunning, true);
    await prefs.setInt(_kStartAt, nowTask.startAt.millisecondsSinceEpoch);
    await prefs.setString(_kTaskName, nowTaskname);
    await prefs.setBool(_kMode, mode);
  }

  Future<void> _clearRunningTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRunning, false);
    await prefs.remove(_kStartAt);
    await prefs.remove(_kTaskName);
    await prefs.remove(_kMode);
  }

  Future<void> _restoreRunningTimerIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final running = prefs.getBool(_kRunning) ?? false;
    if (!running) return;

    final startMs = prefs.getInt(_kStartAt);
    if (startMs == null) {
      // 데이터가 깨졌으면 정리
      await _clearRunningTimer();
      return;
    }

    final restoredStartAt = DateTime.fromMillisecondsSinceEpoch(startMs);
    final restoredName = prefs.getString(_kTaskName) ?? '';
    final restoredMode = prefs.getBool(_kMode) ?? true;

    // 복원
    mode = restoredMode;
    nowTaskname = restoredName;
    timerStarted = true;

    nowTask.setTaskName(nowTaskname);
    nowTask.setStartAt(restoredStartAt);
  }

  @override
  Widget build(BuildContext context) {
    final ad = context.watch<ADTimeController>();

    if (!ad.loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final adTimeValue = ad.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (!timerStarted) ...[
            const Spacer(flex: 15),
            Expanded(flex: 10, child: AttackDefence(ADTime: adTimeValue)),
            const Spacer(flex: 10),
            Expanded(
              flex: 55,
              child: PlayButton(
                mode: mode,
                timerStarted: timerStarted,
                onPressed: onPlayButtonPressed,
              ),
            ),
            const Spacer(flex: 10),
            Expanded(flex: 5, child: ModeSelector(mode: mode, modeChanged: modeChanged)),
            const Spacer(flex: 5),
          ] else ...[
            const Spacer(flex: 20),
            Expanded(
              flex: 10,
              child: Text(
                nowTaskname,
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            Expanded(
              flex: 55,
              child: PlayButton(
                mode: mode,
                timerStarted: timerStarted,
                onPressed: onPlayButtonPressed,
              ),
            ),
            Expanded(
              flex: 15,
              child: TimerWidget(
                startAt: nowTask.startAt,
                running: timerStarted,
              ),
            ),
            const Spacer(flex: 5),
          ],
        ],
      ),
    );
  }
}
