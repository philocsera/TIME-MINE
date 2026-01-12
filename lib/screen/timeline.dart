import 'package:timemine/core/core.dart';
import 'package:timemine/core/today_sessions.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key, required this.targetDate});

  final DateTime targetDate;

  @override
  State<Timeline> createState() => TimelineState();
}

class TimelineState extends State<Timeline> {
  TodaysSessions? _target;
  DateTime? _loadingFor;

  @override
  void initState() {
    super.initState();
    loadData();
  }


  @override
  void didUpdateWidget(covariant Timeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      _reloadFor(widget.targetDate);
    }
  }

  Future<void> _reloadFor(DateTime date) async {
    setState(() {
      _target = null;
      _loadingFor = date;
    });

    final db = context.read<AppDB>();
    final targetSessions = await db.loadSessions(date);

    if (!mounted || _loadingFor != date) return;

    setState(() {
      _target = targetSessions;
    });
  }

  Future<void> loadData() async {
    final db = context.read<AppDB>();
    final targetSessions = await db.loadSessions(widget.targetDate);
    setState(() {
      _target = targetSessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_target == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final t = _target!;

    final items = t.items;
    if (items.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('날짜: ${t.date.toLocal()}'),
          const SizedBox(height: 8),
          const Text('세션이 없습니다.'),
        ],
      );
    }

    return ListView(
      children: [
        Text('날짜: ${_target!.date.toLocal()}'),
        const Divider(),
        ..._target!.items.map((s) => ListTile(
              title: Text(s.taskName),
              subtitle: Text(
                '${s.startAt} ~ ${s.endAt ?? '-'}',
              ),
            )),

      ],
    );
  }
}