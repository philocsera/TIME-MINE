import 'package:timemine/data/app_db.dart';

class TodaysSessions {
  final DateTime date;
  final List<Session> items;
  final int count;
  final int totalDurationSec;

  const TodaysSessions({
    required this.date,
    required this.items,
    required this.count,
    required this.totalDurationSec,
  });
}
