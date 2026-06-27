import 'package:flutter/foundation.dart';
import 'package:timemine/core/classes/attack_defense_time.dart';
import 'package:timemine/core/classes/adtime_store.dart';

class ADTimeController extends ChangeNotifier {
  AttackDefenseTime value = AttackDefenseTime();
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final hasData = await ADTimeStore.hasSavedData();
    if (hasData) {
      value = await ADTimeStore.load();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> restore(Duration deletedTaskTime, bool mode) async {
    value.timeRestore(deletedTaskTime, mode);
    notifyListeners();
    await ADTimeStore.save(value);
  }

  Future<void> increment(Duration d, bool mode) async {
    value.timeIncremented(d, mode);
    notifyListeners();
    await ADTimeStore.save(value);
  }

  Future<void> reset() async {
    value.resetTime();
    notifyListeners();
    await ADTimeStore.save(value);
  }
}
