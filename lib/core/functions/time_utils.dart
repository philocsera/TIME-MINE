import 'package:intl/intl.dart';

DateTime startOfLocalDay(DateTime d) {
  final l = d.toLocal();
  return DateTime(l.year, l.month, l.day);
}

int toDateKey(DateTime d) {
  final l = d.toLocal();
  return l.year * 10000 + l.month * 100 + l.day;
}

// ISO 스타일: 주 시작 = 월요일
int toWeekStartKey(DateTime d) {
  final l = startOfLocalDay(d);
  final daysFromMonday = (l.weekday + 6) % 7; // Mon(1)->0, Sun(7)->6
  final monday = l.subtract(Duration(days: daysFromMonday));
  return toDateKey(monday);
}

({int year, int month}) yearMonthOf(DateTime d) {
  final l = d.toLocal();
  return (year: l.year, month: l.month);
}