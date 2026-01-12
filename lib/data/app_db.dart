import 'package:drift/drift.dart';

import 'package:timemine/data/connection.dart';
import 'package:timemine/core/sessions.dart';
import 'package:timemine/core/today_sessions.dart';
import 'package:timemine/core/time_utils.dart';


part 'app_db.g.dart';

@DriftDatabase(tables: [Sessions])
class AppDB extends _$AppDB {
  AppDB() : super(openConnection());
  @override
  int get schemaVersion => 1;

  Future<int> insertSession(SessionsCompanion arg) =>
      into(sessions).insert(arg);

  Future<TodaysSessions> loadSessions(DateTime target) async {
    final start = startOfDay(target);
    final end = start.add(const Duration(days: 1));

    final rows = await (select(sessions)
          ..where((tbl) =>
              tbl.startAt.isBiggerOrEqualValue(start) &
              tbl.startAt.isSmallerThanValue(end)))
        .get();

    final totalDur = rows.fold<int>(0, (sum, r) => sum + (r.durationSec?.toInt() ?? 0));

    return TodaysSessions(
      date: start,
      items: rows,
      count: rows.length,
      totalDurationSec: totalDur,
    );
  }
}
