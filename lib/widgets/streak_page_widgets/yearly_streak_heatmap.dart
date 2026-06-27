import 'package:timemine/core/core.dart';
import 'package:timemine/widgets/streak_page_widgets/streak_heatmap.dart';


// ==============================
// Yearly Heatmap (fills height)
// ==============================
class YearlyStreakHeatmap extends StatefulWidget {
  const YearlyStreakHeatmap({
    super.key,
    required this.year,
    this.cellSize = 16,
    this.gap = 2,
    this.onTapDay,
  });

  final int year;
  final double cellSize;
  final double gap;
  final void Function(int month, int day)? onTapDay;

  @override
  State<YearlyStreakHeatmap> createState() => _YearlyStreakHeatmapState();
}

class _YearlyStreakHeatmapState extends State<YearlyStreakHeatmap> {
  late List<Future<MonthlyStreak>> _monthFutures;

  @override
  void initState() {
    super.initState();
    _monthFutures = List.generate(12, (_) async => <int>[]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = context.read<AppDB>();
      setState(() {
        _monthFutures = List.generate(
          12,
          (i) => db.monthlyStreak(widget.year, i + 1),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 카드 사이 간격 좁힘
    const rowGap = 10.0;
    const colGap = 10.0;

    return Column(
      children: [
        Expanded(child: _buildRow(0, colGap)),
        const SizedBox(height: rowGap),
        Expanded(child: _buildRow(1, colGap)),
        const SizedBox(height: rowGap),
        Expanded(child: _buildRow(2, colGap)),
        const SizedBox(height: rowGap),
        Expanded(child: _buildRow(3, colGap)),
      ],
    );
  }

  Widget _buildRow(int rowIndex, double colGap) {
    final startMonth = rowIndex * 3 + 1;
    return Row(
      children: [
        Expanded(child: _MonthCard(
          year: widget.year,
          month: startMonth,
          future: _monthFutures[startMonth - 1],
          cellSize: widget.cellSize,
          gap: widget.gap,
          onTapDay: widget.onTapDay,
        )),
        SizedBox(width: colGap),
        Expanded(child: _MonthCard(
          year: widget.year,
          month: startMonth + 1,
          future: _monthFutures[startMonth],
          cellSize: widget.cellSize,
          gap: widget.gap,
          onTapDay: widget.onTapDay,
        )),
        SizedBox(width: colGap),
        Expanded(child: _MonthCard(
          year: widget.year,
          month: startMonth + 2,
          future: _monthFutures[startMonth + 1],
          cellSize: widget.cellSize,
          gap: widget.gap,
          onTapDay: widget.onTapDay,
        )),
      ],
    );
  }
}

// ==============================
// Month Card (경계 없음 + 월 텍스트 작게)
// ==============================
class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.year,
    required this.month,
    required this.future,
    required this.cellSize,
    required this.gap,
    required this.onTapDay,
  });

  final int year;
  final int month;
  final Future<MonthlyStreak> future;
  final double cellSize;
  final double gap;
  final void Function(int month, int day)? onTapDay;

  static const _monthShort = <String>[
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ 테두리/경계 없음
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26), // 카드 둥글게
        boxShadow: const [],
      ),
      // ✅ 내부 패딩 살짝 줄여서 히트맵이 더 커 보이게
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        children: [
          // ✅ 월 텍스트 더 작게
          Text(
            _monthShort[month - 1],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16, // 🔽 줄임
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Center(
              child: FutureBuilder<MonthlyStreak>(
                future: future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  final streak = snapshot.data!;
                  return MonthlyStreakHeatmap(
                    year: year,
                    month: month,
                    monthlyStreak: streak,
                    cellSize: cellSize,
                    gap: gap,
                    onTapDay: onTapDay == null ? null : (day) => onTapDay!(month, day),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
