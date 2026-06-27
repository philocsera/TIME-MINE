// lib/data/app_db.dart
import 'package:drift/drift.dart';

import 'package:timemine/data/connection.dart';
import 'package:timemine/data/tables/sessions.dart';
import 'package:timemine/core/classes/today_sessions.dart';
import 'package:timemine/core/functions/time_utils.dart';
import 'package:timemine/data/tables/daily_stats.dart';
import 'package:timemine/data/tables/title_items.dart';


part 'app_db.g.dart';

// 1-based 인덱스를 쓰기 위해 [0]은 dummy로 비워둡니다.
typedef MonthlyStreak = List<int>;
typedef WeeklyStreak = List<int>;

@DriftDatabase(tables: [Sessions, DailyStats, TitleItems])
class AppDB extends _$AppDB {
  AppDB() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll(); // Sessions + DailyStats
          await customStatement(
              'CREATE INDEX IF NOT EXISTS daily_stats_year_idx ON daily_stats (year)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS daily_stats_month_idx ON daily_stats (year, month)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS daily_stats_week_idx ON daily_stats (week_start_key)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dailyStats);
            await customStatement(
                'CREATE INDEX IF NOT EXISTS daily_stats_year_idx ON daily_stats (year)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS daily_stats_month_idx ON daily_stats (year, month)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS daily_stats_week_idx ON daily_stats (week_start_key)');
          }
          if (from < 3) {
            await m.createTable(titleItems);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS title_items_type_idx ON title_items (type)',
            );
          }
        },
      );

  // ================= 기존 API =================

  Future<int> insertSession(SessionsCompanion arg) => into(sessions).insert(arg);

  Future<TodaysSessions> loadSessions(DateTime target) async {
    final start = startOfLocalDay(target);
    final end = start.add(const Duration(days: 1));

    final rows = await (select(sessions)
          ..where((tbl) =>
              tbl.startAt.isBiggerOrEqualValue(start) &
              tbl.startAt.isSmallerThanValue(end)))
        .get();

    final totalDur =
        rows.fold<int>(0, (sum, r) => sum + (r.durationSec?.toInt() ?? 0));

    return TodaysSessions(
      date: start,
      items: rows,
      count: rows.length,
      totalDurationSec: totalDur,
    );
  }

  Future<void> clearAll() async => await delete(sessions).go();

  // ================= DailyStats API =================

  /// 날짜의 값을 절대치로 upsert (없으면 insert, 있으면 value 교체)
  Future<void> upsertDailyStat(DateTime dayLocal, int value) async {
    final ymd = startOfLocalDay(dayLocal);
    final dateKeyVal = toDateKey(ymd);
    final weekKey = toWeekStartKey(ymd);
    final ym = yearMonthOf(ymd);

    await into(dailyStats).insertOnConflictUpdate(
      DailyStatsCompanion.insert(
        dateKey: Value(dateKeyVal),      // ★ 기본키/필수 컬럼은 int 그대로
        year: ym.year,
        month: ym.month,
        weekStartKey: weekKey,
        value: Value(value),      // ★ default 있는 컬럼은 Value(...)
      ),
    );
  }

  /// 날짜의 현재 값을 읽기 (없으면 null)
  Future<int?> getDailyValue(DateTime dayLocal) async {
    final key = toDateKey(startOfLocalDay(dayLocal));
    final row = await (select(dailyStats)..where((t) => t.dateKey.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setDaily(DateTime dayLocal, int newValue) async {
    final key = toDateKey(startOfLocalDay(dayLocal));
    final value = Value(newValue);

    await transaction(() async {
      final current =
          await (select(dailyStats)..where((t) => t.dateKey.equals(key)))
              .getSingleOrNull();

      if (current == null) {
        final ymd = startOfLocalDay(dayLocal);
        final ym = yearMonthOf(ymd);

        await into(dailyStats).insert(
          DailyStatsCompanion.insert(
            dateKey: Value(key),
            year: ym.year,
            month: ym.month,
            weekStartKey: toWeekStartKey(ymd),
            value: value,
          ),
        );
      } else {
        await (update(dailyStats)..where((t) => t.dateKey.equals(key))).write(
          DailyStatsCompanion(value: value),
        );
      }
    });
  }


  /// 임의 기간: "YYYYMMDD -> value" (날짜 없는 날은 0으로 채움)
  Future<List<({int dateKey, int value})>> dailyByRange(
    DateTime startLocal,
    DateTime endLocalInclusive,
  ) async {
    final sKey = toDateKey(startOfLocalDay(startLocal));
    final eKey = toDateKey(startOfLocalDay(endLocalInclusive));

    final rows = await (select(dailyStats)
          ..where((t) => t.dateKey.isBetweenValues(sKey, eKey))
          ..orderBy([(t) =>
              OrderingTerm(expression: t.dateKey, mode: OrderingMode.asc)]))
        .get();

    // 조회된 것 맵으로
    final map = <int, int>{for (final r in rows) r.dateKey: r.value};

    // 빠진 날짜 0으로 채워서 반환
    final result = <({int dateKey, int value})>[];
    var cur = startOfLocalDay(startLocal);
    final end = startOfLocalDay(endLocalInclusive);
    while (!cur.isAfter(end)) {
      final key = toDateKey(cur);
      result.add((dateKey: key, value: map[key] ?? 0));
      cur = cur.add(const Duration(days: 1));
    }
    return result;
  }

  // ================== 새로 추가: Streak API ==================

  /// 월간: MonthlyStreak[1] = 그 달 1일 값 (없으면 0)
  Future<MonthlyStreak> monthlyStreak(int year, int month) async {
    final start = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final end = DateTime(year, month, lastDay);

    final tuples = await dailyByRange(start, end);

    // 1-based 인덱싱: 길이 = lastDay + 1, [0]은 dummy 0
    final streak = List<int>.filled(lastDay + 1, 0, growable: false);
    for (final t in tuples) {
      final d = int.parse(t.dateKey.toString().substring(6, 8)); // ...YYYYMMDD
      streak[d] = t.value;
    }
    return streak;
  }

  /// 주간: WeeklyStreak[1] = 그 주 첫째 날(월요일) 값, 길이 8 ([0] dummy)
  Future<WeeklyStreak> weeklyStreak(DateTime anyDayLocal) async {
    // 주 시작(월요일) 계산
    final base = startOfLocalDay(anyDayLocal);
    final daysFromMonday = (base.weekday + 6) % 7; // Mon=1 -> 0
    final monday = base.subtract(Duration(days: daysFromMonday));
    final sunday = monday.add(const Duration(days: 6));

    final tuples = await dailyByRange(monday, sunday);

    // 1-based 인덱싱: [1..7], [0] dummy
    final streak = List<int>.filled(8, 0, growable: false);
    for (var i = 0; i < tuples.length; i++) {
      // i: 0..6 -> dayIndex: 1..7
      streak[i + 1] = tuples[i].value;
    }
    return streak;
  }

  /// DailyStats만 비우기
  Future<void> clearDailyStats() async => await delete(dailyStats).go();

  Future<void> deleteSessionById(int id) async {
    await (delete(sessions)..where((t) => t.id.equals(id))).go();
  }

  // ===== Titles API =====

  /// type 하나의 titles를 "통째로 교체" 저장
  /// 예) type="video", titles=["Youtube","Novel"]
  Future<void> saveTitlesForType(String type, List<String> titles) async {
    await transaction(() async {
      // 기존 삭제
      await (delete(titleItems)..where((t) => t.type.equals(type))).go();

      // 새로 삽입
      for (var i = 0; i < titles.length; i++) {
        final t = titles[i].trim();
        if (t.isEmpty) continue;

        await into(titleItems).insert(
          TitleItemsCompanion.insert(
            type: type,
            title: t,
            sort: Value(i),
          ),
          // uniqueKeys 충돌 시 무시(원하면 replace로 바꿔도 됨)
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// type 하나의 titles 로드 (sort 순)
  Future<List<String>> loadTitlesForType(String type) async {
    final rows = await (select(titleItems)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm(expression: t.sort)]))
        .get();
    return rows.map((r) => r.title).toList();
  }

  /// 전체를 Map<String, List<String>>로 로드
  Future<Map<String, List<String>>> loadAllTitlesAsMap() async {
    final rows = await (select(titleItems)
          ..orderBy([
            (t) => OrderingTerm(expression: t.type),
            (t) => OrderingTerm(expression: t.sort),
          ]))
        .get();

    final map = <String, List<String>>{};
    for (final r in rows) {
      (map[r.type] ??= <String>[]).add(r.title);
    }
    return map;
  }

  /// title 하나 추가 (중복은 uniqueKeys로 막힘)
  Future<void> addTitle(String type, String title) async {
    final t = title.trim();
    if (t.isEmpty) return;

    // sort는 가장 뒤로 붙이기
    final maxSortExpr = titleItems.sort.max();
    final maxRow = await (selectOnly(titleItems)
          ..addColumns([maxSortExpr])
          ..where(titleItems.type.equals(type)))
        .getSingleOrNull();
    final nextSort = (maxRow?.read(maxSortExpr) ?? -1) + 1;

    await into(titleItems).insert(
      TitleItemsCompanion.insert(
        type: type,
        title: t,
        sort: Value(nextSort),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// title 하나 삭제
  Future<void> deleteTitle(String type, String title) async {
    await (delete(titleItems)
          ..where((t) => t.type.equals(type) & t.title.equals(title)))
        .go();
  }

}
