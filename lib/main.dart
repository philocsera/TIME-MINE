import 'package:shared_preferences/shared_preferences.dart';

import 'package:timemine/core/core.dart';
import 'package:timemine/core/notifiers/app_settings.dart';
import 'package:timemine/core/functions/show_add_task_dialog.dart';

import 'package:timemine/screen/timer_home.dart';
import 'package:timemine/screen/timeline.dart';
import 'package:timemine/screen/streak_page.dart';
import 'package:timemine/screen/setting_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDB();
  final settings = AppSettings();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDB>.value(value: db),
        ChangeNotifierProvider<AppSettings>.value(value: settings),
        ChangeNotifierProvider<ADTimeController>(
          create: (_) => ADTimeController()..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'VITRO_PRIDE',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.white12,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const TimeMine(),
    );
  }
}

class TimeMine extends StatefulWidget {
  const TimeMine({super.key});

  @override
  State<TimeMine> createState() => _TimeMineState();
}

class _TimeMineState extends State<TimeMine> with WidgetsBindingObserver {
  int _currentIdx = 0;

  final _timelineKey = GlobalKey<TimelinePageState>();
  final _timerHomeKey = GlobalKey<TimerHomeState>();
  final _bucket = PageStorageBucket();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pages = [
      TimerHome(key: _timerHomeKey),
      TimelinePage(key: _timelineKey, initialDate: DateTime.now()),
      const StreakPage(key: PageStorageKey('StreakPage')),
      const SettingsPage(key: PageStorageKey('SettingsPage')),
    ];

    _checkTimeAndRun();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTimeAndRun();
    }
  }

  DateTime getLogicalToday(DateTime now, int dayStartMinutes) {
    final nowMinutes = now.hour * 60 + now.minute;

    if (nowMinutes < dayStartMinutes) {
      return DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
    }

    return DateTime(now.year, now.month, now.day);
  }
    
  Future<void> _checkTimeAndRun() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final settings = context.read<AppSettings>();
    final now = DateTime.now();
    
    final logicalToday = getLogicalToday(now, settings.dayStartMinutes);
    // ✅ 월(month)과 일(day) 모두 두 자리 형식을 유지합니다.
    final todayKey = "${logicalToday.year}-${logicalToday.month.toString().padLeft(2, '0')}-${logicalToday.day.toString().padLeft(2, '0')}";

    final lastRunDate = prefs.getString('lastRunDate');
    
    debugPrint("DEBUG: LastRun: $lastRunDate, CurrentKey: $todayKey");

    if (lastRunDate != todayKey) {
      final db = context.read<AppDB>();
      final adController = context.read<ADTimeController>();
      
      try {
        // adtime_store.dart 수정 후 호출
        final statusValue = await ADTimeStore.getDailyStreakStatus();
        await db.setDaily(now, statusValue);
        await adController.reset();
        await prefs.setString('lastRunDate', todayKey);
        
        debugPrint("✅ 리셋 성공!");
      } catch (e) {
        debugPrint("❌ 리셋 중 오류 발생: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _currentIdx,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        // 핵심: UI상에서 보여줄 선택 인덱스를 계산해서 전달
        selectedIndex: _currentIdx >= 2 ? _currentIdx + 1 : _currentIdx, 
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (i) async {
          // 1. 추가 버튼(가운데) 처리
          if (i == 2) {
            await showAddTaskDialog(context);
            return; // 페이지 전환은 하지 않음
          }

          // 2. 실제 페이지 인덱스로 변환 (i가 3, 4일 때 1을 빼줌)
          int actualPageIdx = i > 2 ? i - 1 : i;

          setState(() => _currentIdx = actualPageIdx);

          // 3. 타임라인 탭 클릭 시 새로고침 로직
          if (actualPageIdx == 1) {
            _timelineKey.currentState?.reloadFor(DateTime.now());
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer, color: Colors.white), label: ''),      // i=0 -> page=0
          NavigationDestination(icon: Icon(Icons.timeline, color: Colors.white), label: ''),   // i=1 -> page=1
          NavigationDestination(icon: Icon(Icons.add, color: Colors.white), label: ''),        // i=2 -> Action
          NavigationDestination(icon: Icon(Icons.emoji_events, color: Colors.white), label: ''),// i=3 -> page=2
          NavigationDestination(icon: Icon(Icons.settings, color: Colors.white), label: ''),    // i=4 -> page=3
        ],
      ),
    );
  }
}