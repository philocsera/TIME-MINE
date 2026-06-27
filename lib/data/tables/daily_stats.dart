import 'package:drift/drift.dart' as drift;

class DailyStats extends drift.Table {
  drift.IntColumn get dateKey => integer()();
  drift.IntColumn get value => integer().withDefault(const drift.Constant(0))();
  drift.IntColumn get year => integer()();
  drift.IntColumn get month => integer()();
  drift.IntColumn get weekStartKey => integer()();

  @override
  Set<drift.Column> get primaryKey => {dateKey};

  @override
  List<drift.Index> get indexes => [
    drift.Index(
      'daily_stats',
      'CREATE INDEX IF NOT EXISTS daily_stats_year_idx ON daily_stats (year)',
    ),
    drift.Index(
      'daily_stats',
      'CREATE INDEX IF NOT EXISTS daily_stats_month_idx ON daily_stats (year, month)',
    ),
    drift.Index(
      'daily_stats',
      'CREATE INDEX IF NOT EXISTS daily_stats_week_idx ON daily_stats (week_start_key)',
    ),
  ];
}
