import 'package:shared_preferences/shared_preferences.dart';
import 'package:timemine/core/classes/attack_defense_time.dart';

class ADTimeStore {
  static const _kGoalAttackMin = 'ad_goal_attack_min';
  static const _kGoalDefenseMin = 'ad_goal_defense_min';
  static const _kCurrentAttackMin = 'ad_current_attack_min';
  static const _kCurrentDefenseMin = 'ad_current_defense_min';
  static const _kAttackSet = 'ad_attack_set';
  static const _kDefenseSet = 'ad_defense_set';

  static Future<void> save(AttackDefenseTime t) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kGoalAttackMin, t.targetAttackTime.inMinutes);
    await p.setInt(_kGoalDefenseMin, t.targetDefenseTime.inMinutes);
    await p.setInt(_kCurrentAttackMin, t.currentAttackTime.inMinutes);
    await p.setInt(_kCurrentDefenseMin, t.currentDefenseTime.inMinutes);
    await p.setBool(_kAttackSet, t.attackTimeSeted);
    await p.setBool(_kDefenseSet, t.defenseTimeSeted);
  }

  static Future<AttackDefenseTime> load() async {
    final p = await SharedPreferences.getInstance();
    final t = AttackDefenseTime();
    final atkMin = p.getInt(_kGoalAttackMin);
    final defMin = p.getInt(_kGoalDefenseMin);
    t.targetAttackTime = Duration(minutes: atkMin ?? 0);
    t.targetDefenseTime = Duration(minutes: defMin ?? 0);
    t.currentAttackTime = Duration(minutes: p.getInt(_kCurrentAttackMin) ?? 0);
    t.currentDefenseTime = Duration(minutes: p.getInt(_kCurrentDefenseMin) ?? 0);
    t.attackTimeSeted = p.getBool(_kAttackSet) ?? false;
    t.defenseTimeSeted = p.getBool(_kDefenseSet) ?? false;
    return t;
  }

  static Future<bool> hasSavedData() async {
    final p = await SharedPreferences.getInstance();
    final atk = p.containsKey(_kGoalAttackMin);
    final def = p.containsKey(_kGoalDefenseMin);
    return atk || def;
  }

  static Future<int> getDailyStreakStatus() async {
    final p = await SharedPreferences.getInstance();
    
    // ✅ 수정: getInt가 아니라 getBool로 읽어야 합니다.
    final bool attackSet = p.getBool(_kAttackSet) ?? false;
    final bool defenseSet = p.getBool(_kDefenseSet) ?? false;

    if(attackSet && defenseSet) {
      final goalAtk = p.getInt(_kGoalAttackMin);
      final goalDef = p.getInt(_kGoalDefenseMin);
      final currAtk = p.getInt(_kCurrentAttackMin);
      final currDef = p.getInt(_kCurrentDefenseMin);

      if(goalAtk == null || goalDef == null || currAtk == null || currDef == null) {
        return 0;
      }

      int attackTime = goalAtk - currAtk;
      int defenseTime = goalDef - currDef;
      
      if(attackTime <= 0 && defenseTime > 0) {
        return 3;
      } else if (attackTime <= 0) {
        return 1;
      } else if (defenseTime > 0) {
        return 2;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();

    await p.remove(_kGoalAttackMin);
    await p.remove(_kGoalDefenseMin);
    await p.remove(_kCurrentAttackMin);
    await p.remove(_kCurrentDefenseMin);
    await p.remove(_kAttackSet);
    await p.remove(_kDefenseSet);
  }
}
