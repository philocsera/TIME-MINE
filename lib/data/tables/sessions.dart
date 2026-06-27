import 'package:drift/drift.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskName => text()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  BoolColumn get mode => boolean().withDefault(const Constant(false))();
  
  IntColumn get durationSec => integer().withDefault(const Constant(0))();
}