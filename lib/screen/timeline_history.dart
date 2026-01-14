
import 'package:timemine/core/core.dart';
import 'package:timemine/screen/timeline.dart';

class TimelineHistory extends StatefulWidget {
  const TimelineHistory({super.key});

  @override
  State<TimelineHistory> createState() => TimelineHistoryState();
}

class TimelineHistoryState extends State<TimelineHistory> {
  DateTime target = DateTime.now();

  void setDate () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
    );
    setState(() {
      if (picked != null) {
        target = picked;
      }
    });
}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 1),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: setDate,
            child: const Text('날짜 선택하기'),
          ),
        ),
        Expanded(
          flex: 8,
          child: TimelinePage(targetDate: target)
        ),
      ]
    );;
  }
}