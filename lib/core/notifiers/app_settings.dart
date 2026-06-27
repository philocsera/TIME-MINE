import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _kDayStartMinutes = 'settings_day_start_minutes';

  int _dayStartMinutes = 4 * 60;
  int get dayStartMinutes => _dayStartMinutes;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _dayStartMinutes = p.getInt(_kDayStartMinutes) ?? (4 * 60);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDayStartMinutes(int minutes) async {
    final v = minutes.clamp(0, 1439);
    if (_dayStartMinutes == v) return;

    _dayStartMinutes = v;
    notifyListeners();

    final p = await SharedPreferences.getInstance();
    await p.setInt(_kDayStartMinutes, v);
  }

  int get dayStartHour => _dayStartMinutes ~/ 60;
  int get dayStartMinute => _dayStartMinutes % 60;
}
