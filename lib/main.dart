import 'package:timemine/core/core.dart';
import 'package:timemine/screen/timer_home.dart';
import 'package:timemine/screen/timeline.dart';
import 'package:timemine/screen/setting_page.dart';
import 'package:timemine/screen/timeline_history.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDB();
  runApp(
    Provider<AppDB>.value(
      value: db,
      child: const TimeMine(),
    )
  );
}

class TimeMine extends StatefulWidget {
  const TimeMine({super.key});

  @override
  State<TimeMine> createState() => _TimeMineState();
}

class _TimeMineState extends State<TimeMine> {
  int _currentIdx = 0;
  final _timelineKey = GlobalKey<TimelinePageState>();
  final _bucket = PageStorageBucket();
  late final List<Widget> _pages;

  @override
  void initState(){
    super.initState();
    _pages = [ // 상태 유지를 위한 Key 포함
      const TimerHome(key: PageStorageKey('TimerHome')),
      TimelinePage(key: _timelineKey, targetDate: DateTime.now()),
      const TimelineHistory(key: PageStorageKey('TimelineHistory')),
      const SettingsPage(key: PageStorageKey('SettingsPage')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
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
      home: 
        Scaffold(
          body: PageStorage(
            bucket: _bucket,
            child: IndexedStack(
              index: _currentIdx,
              children: _pages,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIdx,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, 
            onDestinationSelected: (i) {
              setState(() => _currentIdx = i);
              if(i == 1){
                _timelineKey.currentState?.reloadFor(DateTime.now());
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.timer, color:Colors.white), label: ''),
              NavigationDestination(icon: Icon(Icons.timeline, color:Colors.white), label: ''),
              NavigationDestination(icon: Icon(Icons.history, color:Colors.white), label: ''),
              NavigationDestination(icon: Icon(Icons.settings, color:Colors.white), label: ''),
            ],
          ),
        ),
      );
  } 
}