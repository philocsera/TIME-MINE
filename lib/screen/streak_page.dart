import 'package:timemine/widgets/streak_page_widgets/yearly_streak_heatmap.dart';
import 'package:timemine/core/core.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  MonthlyStreak? _streak;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final db = context.read<AppDB>();
    final s = await db.monthlyStreak(2026, 1);
    setState(() => _streak = s);
  }

  Future<void> onPickDate() async {
    final now = DateTime.now();

    // 현재 선택된 연도를 유지한 채로 YearPicker를 열기
    final int initialYear = _date.year;

    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('연도 선택'),
          content: SizedBox(
            width: 320,
            height: 360,
            child: YearPicker(
              firstDate: DateTime(2026),
              lastDate: DateTime(now.year),
              selectedDate: DateTime(initialYear),
              onChanged: (DateTime selected) {
                Navigator.of(context).pop(selected.year);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    if (pickedYear != null) {
      // 연도만 바꾸고, month/day는 안전하게 1/1로 고정(또는 기존 month/day 유지해도 됨)
      setState(() => _date = DateTime(pickedYear, 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_streak == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Row(
            children: [
              Icon(Icons.emoji_events, size: 20),
              SizedBox(width: 8),
              Text('Streaks'),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(_date.year.toString()),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: YearlyStreakHeatmap(
            year: _date.year,
          ),
        ),
      );
  }
}
