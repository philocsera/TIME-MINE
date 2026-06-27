import 'package:drift/drift.dart' show Value;

import 'package:timemine/core/core.dart';
import 'package:timemine/core/classes/task_dialong_result.dart';

enum TaskMode { attack, defense }

Future<TaskDialogResult?> showAddTaskDialog(BuildContext context) {
  return showDialog<TaskDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String taskName = '';

      final today = DateTime.now();
      DateTime start = DateTime(
        today.year,
        today.month,
        today.day,
        today.hour,
        today.minute,
      );
      DateTime end = start;

      TaskMode mode = TaskMode.attack;

      const double labelWidth = 90;

      String format(DateTime dt) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }

      Future<DateTime?> pickTime(DateTime base) async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(base),
        );
        if (picked == null) return null;

        return DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        );
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 340,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Task Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: labelWidth,
                          child: Text('Task Name'),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (v) => taskName = v,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Start
                    InkWell(
                      onTap: () async {
                        final picked = await pickTime(start);
                        if (picked != null) {
                          setState(() => start = picked);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: labelWidth,
                            child: Text('Start'),
                          ),
                          Text(format(start)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// End
                    InkWell(
                      onTap: () async {
                        final picked = await pickTime(end);
                        if (picked != null) {
                          setState(() => end = picked);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: labelWidth,
                            child: Text('End'),
                          ),
                          Text(format(end)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

        /// Mode
/// Mode
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const SizedBox(
      width: 90,
      child: Text('Mode'),
    ),
    Expanded(
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Attack'),
            selected: mode == TaskMode.attack,
            onSelected: (_) {
              setState(() => mode = TaskMode.attack);
            },
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Defense'),
            selected: mode == TaskMode.defense,
            onSelected: (_) {
              setState(() => mode = TaskMode.defense);
            },
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          ),
        ],
      ),
    ),
  ],
),


                    const SizedBox(height: 28),

                    /// Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final isAttack = mode == TaskMode.attack;

                            final db = context.read<AppDB>();
                            await db.insertSession(
                              SessionsCompanion.insert(
                                taskName: taskName,
                                startAt: start,
                                endAt: end,
                                mode: Value(isAttack),
                              ),
                            );

                            await context
                                .read<ADTimeController>()
                                .increment(
                                  end.difference(start),
                                  isAttack,
                                );

                            Navigator.pop(
                              context,
                              TaskDialogResult(
                                taskName: taskName,
                                start: start,
                                end: end,
                                mode: isAttack,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
