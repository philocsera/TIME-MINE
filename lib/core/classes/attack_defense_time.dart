import 'package:timemine/core/classes/adtime_store.dart';

class AttackDefenseTime {
  Duration targetAttackTime = Duration.zero;
  Duration targetDefenseTime = Duration.zero;
  Duration currentAttackTime = Duration.zero;
  Duration currentDefenseTime = Duration.zero;
  bool attackTimeSeted = false;
  bool defenseTimeSeted = false;

  void timeChanged(Duration newAttackTime, bool mode){ 
    if(mode){
      targetAttackTime = newAttackTime; 
      attackTimeSeted = true;
    } else{
      targetDefenseTime = newAttackTime; 
      defenseTimeSeted = true;
    }
    ADTimeStore.save(this);
  }

  void timeIncremented(Duration nowTaskTime, bool mode){
    if(mode){
      currentAttackTime += nowTaskTime;
    } else{
      currentDefenseTime += nowTaskTime;
    }
    ADTimeStore.save(this);
  }

  void timeRestore(Duration deletedTaskTime, bool mode){
    if(mode){
      currentAttackTime -= deletedTaskTime;
    }else{
      currentDefenseTime -= deletedTaskTime;
    }
    ADTimeStore.save(this);
  }

  Duration remainingTime(bool mode){
    if(mode){
      final remaining = targetAttackTime - currentAttackTime;
      return remaining.isNegative ? Duration.zero : remaining;
    } else{
      final remaining = targetDefenseTime - currentDefenseTime;
      return remaining.isNegative ? Duration.zero : remaining;
    }
  }

  void resetTime(){
    targetAttackTime = Duration.zero;
    targetDefenseTime = Duration.zero;
    currentAttackTime = Duration.zero;
    currentDefenseTime = Duration.zero;
    attackTimeSeted = false;
    defenseTimeSeted = false;
    ADTimeStore.clear();
  }
}