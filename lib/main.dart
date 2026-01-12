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
  final _timelineKey = GlobalKey<TimelineState>();
  final _bucket = PageStorageBucket();
  late final List<Widget> _pages;

  @override
  void initState(){
    super.initState();
    _pages = [ // 상태 유지를 위한 Key 포함
      const TimerHome(key: PageStorageKey('TimerHome')),
      Timeline(key: _timelineKey, targetDate: DateTime.now()),
      const TimelineHistory(key: PageStorageKey('TimelineHistory')),
      const SettingsPage(key: PageStorageKey('SettingsPage')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: 
        Scaffold(
          body: PageStorage(
            bucket: _bucket,
            child: IndexedStack(
              index: _currentIdx,
              children: _pages,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIdx,
            onTap: (i) {
              setState(() => _currentIdx = i);
              if(i == 1){
                // 타임라인 새로고침
                _timelineKey.currentState?.loadData();
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timer, color: Colors.black,),
                label: 'Timer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline, color: Colors.black,),
                label: 'Timeline',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history, color: Colors.black,),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings, color: Colors.black,),
                label: 'Settings',
              ),
            ],
          ),
        ),
    );
  }
}