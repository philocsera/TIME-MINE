import 'package:timemine/core/core.dart';
import 'package:timemine/core/today_sessions.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key, required this.targetDate});
  final DateTime targetDate;

  @override
  State<TimelinePage> createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  TodaysSessions? _target;
  DateTime? _loadingFor;

  @override
  void initState() {
    super.initState();
    _reloadFor(widget.targetDate);
  }

  @override
  void didUpdateWidget(covariant TimelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      _reloadFor(widget.targetDate);
    }
  }

  Future<void> reloadFor(DateTime date) => _reloadFor(date);

  Future<void> _reloadFor(DateTime date) async {
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

  bool _sameHM(DateTime a, DateTime b) => a.hour == b.hour && a.minute == b.minute;

  @override
  Widget build(BuildContext context) {
    if (_target == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        appBar: _TimelineAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = List.of(_target!.items);

    if (items.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        appBar: _TimelineAppBar(),
        body: Center(
          child: Text(
            '기록이 없습니다',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    items.sort((a, b) => a.startAt.compareTo(b.startAt));

    const double pxPerMinute = 0.8;     
    const double minSessionHeight = 88.0;  
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
    for (int i = 0; i < items.length; i++) {
      final row = items[i];

      final DateTime startAt = row.startAt;
      final DateTime? rawEnd = row.endAt;
      final DateTime endAt = rawEnd ?? startAt;

      if (prevEnd != null && startAt.isAfter(prevEnd!)) {
        final gap = startAt.difference(prevEnd!);
        segs.add(_Seg.gap(
          height: toHeight(gap, minH: minGapHeight, maxH: maxGapHeight),
        ));
      }

      final String taskName =
          (row.taskName.trim().isNotEmpty)
              ? row.taskName.trim()
              : '세션';

      final bool same = _sameHM(startAt, endAt);
      final String timeText = (rawEnd == null || same)
          ? _fmtHM(startAt)
          : '${_fmtHM(startAt)} ~ ${_fmtHM(endAt)}';

      final Duration span = endAt.isAfter(startAt) ? endAt.difference(startAt) : Duration.zero;
      final double sessionHeight =
          toHeight(span, minH: minSessionHeight, maxH: maxSessionHeight);

      segs.add(_Seg.session(
        height: sessionHeight,
        timeText: timeText,
        taskName: taskName,
      ));

      prevEnd = endAt.isAfter(startAt) ? endAt : startAt;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const _TimelineAppBar(),
      body: Stack(
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

              final spans = <InlineSpan>[
                TextSpan(
                  text: seg.timeText ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: seg.taskName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ];

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
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 12, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: spans),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TimelineAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Timeline'),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
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

  _Seg._(
    this.kind, {
    required this.height,
    this.timeText,
    this.taskName,
  });

  factory _Seg.gap({required double height}) =>
      _Seg._(_SegKind.gap, height: height);

  factory _Seg.session({
    required double height,
    required String timeText,
    required String taskName,
  }) =>
      _Seg._(
        _SegKind.session,
        height: height,
        timeText: timeText,
        taskName: taskName,
      );
}
