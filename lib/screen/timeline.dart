import 'package:timemine/core/core.dart';
import 'package:timemine/core/classes/today_sessions.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  State<TimelinePage> createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  TodaysSessions? _target;
  DateTime? _loadingFor;

  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    reloadFor(_date);
  }

  Future<void> _deleteRow(dynamic row, {required String taskName, required String timeText}) async {
    final ok = await _confirmDelete(taskName: taskName, timeText: timeText);
    if (!ok) return;

    final startAt = row.startAt as DateTime;
    final endAt = (row.endAt as DateTime?) ?? startAt;
    final deleted = endAt.isAfter(startAt) ? endAt.difference(startAt) : Duration.zero;

    final mode = row.mode as bool; // Sessions 테이블에 bool mode 저장한다고 가정

    // ✅ DB 삭제 전에 복구 반영
    await context.read<ADTimeController>().restore(deleted, mode);

    // ✅ 그리고 DB 삭제
    final db = context.read<AppDB>();
    await db.deleteSessionById(row.id as int);

    if (!mounted) return;
    await reloadFor(_date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() => _date = picked);
    await reloadFor(picked);
  }

  Future<void> reloadFor(DateTime date) async {
    setState(() {
      _target = null;
      _loadingFor = date;
    });

    final db = context.read<AppDB>();
    final targetSessions = await db.loadSessions(date);

    if (!mounted || _loadingFor != date) return;

    setState(() {
      _target = targetSessions;
    });
  }

  String _fmtHM(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _fmtYMD(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  Future<bool> _confirmDelete({
    required String taskName,
    required String timeText,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          '삭제할까요?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$timeText\n$taskName\n\n이 기록을 삭제하시겠어요?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _TimelineAppBar(
        dateText: _fmtYMD(_date),
        onPickDate: _pickDate,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_target == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = List.of(_target!.items);
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '기록이 없습니다',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    items.sort((a, b) => a.startAt.compareTo(b.startAt));

    const double pxPerMinute = 0.4;
    const double minSessionHeight = 65.0;
    const double minGapHeight = 6.0;
    const double maxGapHeight = 80.0;
    const double maxSessionHeight = 220.0;

    const double leftGutterWidth = 64.0;
    const double axisX = 22.0;

    double toHeight(Duration d, {required double minH, double? maxH}) {
      final minutes = d.inMinutes + (d.inSeconds % 60) / 60.0;
      final raw = minutes * pxPerMinute;
      double h = raw < minH ? minH : raw;
      if (maxH != null && h > maxH) h = maxH;
      return h;
    }

    final List<_Seg> segs = [];
    DateTime? prevEnd;

    for (final row in items) {
      final startAt = row.startAt;
      final endAt = row.endAt ?? startAt;

      if (prevEnd != null && startAt.isAfter(prevEnd)) {
        final gap = startAt.difference(prevEnd);
        segs.add(_Seg.gap(height: toHeight(gap, minH: minGapHeight, maxH: maxGapHeight)));
      }

      final taskName = row.taskName.trim().isNotEmpty ? row.taskName.trim() : '세션';
      final timeText = '${_fmtHM(startAt)} ~ ${_fmtHM(endAt)}';

      final span = endAt.isAfter(startAt) ? endAt.difference(startAt) : Duration.zero;
      final sessionHeight = toHeight(span, minH: minSessionHeight, maxH: maxSessionHeight);

      segs.add(_Seg.session(
        height: sessionHeight,
        timeText: timeText,
        taskName: taskName,
        row: row,
      ));

      prevEnd = endAt.isAfter(startAt) ? endAt : startAt;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _FullHeightAxisPainter(
                x: axisX,
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: segs.length,
          itemBuilder: (context, index) {
            final seg = segs[index];

            if (seg.kind == _SegKind.gap) {
              return SizedBox(height: seg.height);
            }

            final row = seg.row;
            final taskName = seg.taskName ?? '';
            final timeText = seg.timeText ?? '';

            return SizedBox(
              height: seg.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: leftGutterWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: axisX - 6),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          // 1) 왼쪽: 시간 고정
                          Text(
                            timeText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // 2) 가운데: 남는 영역에서 taskName 가운데 정렬
                          Expanded(
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    row.mode == true
                                        ? 'assets/sword.png'
                                        : 'assets/shield.png',
                                    width: 14,
                                    height: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    taskName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                          // 3) 오른쪽: 삭제 버튼 고정
                          IconButton(
                            padding: EdgeInsets.zero,           // 1. 패딩 제거
                            constraints: const BoxConstraints(), // 2. 최소 크기 제약 제거
                            visualDensity: VisualDensity.compact, //
                            tooltip: '삭제',
                            onPressed: () => _deleteRow(
                              row,
                              taskName: taskName,
                              timeText: timeText,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TimelineAppBar({
    required this.dateText,
    required this.onPickDate,
  });

  final String dateText;
  final VoidCallback onPickDate;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: const [
          Icon(Icons.timeline, size: 20),
          SizedBox(width: 8),
          Text('Timeline'),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: onPickDate,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(dateText),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _FullHeightAxisPainter extends CustomPainter {
  final double x;
  final Color color;
  final double strokeWidth;

  _FullHeightAxisPainter({
    required this.x,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _FullHeightAxisPainter oldDelegate) {
    return oldDelegate.x != x ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

enum _SegKind { gap, session }

class _Seg {
  final _SegKind kind;
  final double height;
  final String? timeText;
  final String? taskName;

  // ✅ 세션 삭제를 위해 row를 들고 있게 함
  final dynamic row;

  _Seg._(
    this.kind, {
    required this.height,
    this.timeText,
    this.taskName,
    this.row,
  });

  factory _Seg.gap({required double height}) =>
      _Seg._(_SegKind.gap, height: height);

  factory _Seg.session({
    required double height,
    required String timeText,
    required String taskName,
    required dynamic row,
  }) =>
      _Seg._(
        _SegKind.session,
        height: height,
        timeText: timeText,
        taskName: taskName,
        row: row,
      );
}
