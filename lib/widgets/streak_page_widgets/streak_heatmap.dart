import 'package:timemine/core/core.dart';

class MonthlyStreakHeatmap extends StatelessWidget {
  const MonthlyStreakHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.monthlyStreak,
    this.cellSize = 16, // ✅ 더 크게
    this.gap = 2,       // ✅ 거의 붙게
    this.onTapDay,
  });

  final int year;
  final int month;
  final MonthlyStreak monthlyStreak;

  final double cellSize;
  final double gap;
  final void Function(int day)? onTapDay;

  int _daysInMonth(int y, int m) {
    final firstNextMonth =
        (m == 12) ? DateTime(y + 1, 1, 1) : DateTime(y, m + 1, 1);
    return firstNextMonth.subtract(const Duration(days: 1)).day;
  }

  bool _isSameMonth(DateTime a) => a.year == year && a.month == month;

  // 1-based(길이 days+1) / 0-based(길이 days) 자동 대응
  int _valueForDay(int day, int daysInMonth) {
    if (monthlyStreak.length == daysInMonth + 1) {
      return (day >= 1 && day < monthlyStreak.length) ? monthlyStreak[day] : 0;
    }
    final idx = day - 1;
    return (idx >= 0 && idx < monthlyStreak.length) ? monthlyStreak[idx] : 0;
  }

  Color _filledColor(int v) {
    switch (v) {
      case 1:
        return const Color(0xFFE74C3C);
      case 2:
        return const Color(0xFF3498DB);
      case 3:
        return const Color(0xFF2ECC71);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(year, month);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetMonth = DateTime(year, month, 1);

    final isTargetMonthFuture =
        targetMonth.isAfter(DateTime(today.year, today.month, 1));

    // 색 기준
    const futureColor = Colors.white38; // 미래 날짜용 (반투명)
    const pastFailColor = Colors.white; // 지나간 날 실패(X)용 (흰색)

    return SizedBox(
      height: cellSize * 7 + gap * 6,
      child: GridView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 1,
        ),
        itemCount: days,
        itemBuilder: (context, index) {
          final day = index + 1;

          // 미래 판별
          final isFuture = isTargetMonthFuture ||
              (today.year == year && today.month == month && day > today.day);

          final v = _valueForDay(day, days);

          // 지나간 날인데 streak 없음
          final isPastEmpty = !isFuture && v == 0;

          final fill = isFuture ? Colors.transparent : _filledColor(v);

          // ✅ 테두리 분기
          final Border? border = isFuture
              ? Border.all(color: futureColor, width: 1)
              : (isPastEmpty
                  ? Border.all(color: pastFailColor, width: 1)
                  : null);

          return GestureDetector(
            onTap: onTapDay == null ? null : () => onTapDay!(day),
            child: Container(
              width: cellSize,
              height: cellSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                border: border,
                borderRadius: BorderRadius.circular(4),
              ),
              // ✅ X 색도 분기
              child: isPastEmpty
                  ? const Text(
                      '×',
                      style: TextStyle(
                        color: pastFailColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}