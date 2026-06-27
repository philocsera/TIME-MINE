import 'package:timemine/core/core.dart';

class BracketPainter extends CustomPainter {
  final bool isStart; // 세션 시작 이벤트인가?
  final bool isEnd;   // 세션 종료 이벤트인가?
  final Color color;

  BracketPainter({
    required this.isStart,
    required this.isEnd,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const axisX = 22.0;   // 시간축 X
    const bracketX = 44.0; // 브라켓 세로선 X
    final y = size.height / 2;

    // 1) 시간축 (항상)
    canvas.drawLine(Offset(axisX, 0), Offset(axisX, size.height), axisPaint);

    // 2) 점 (항상)
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(axisX, y), 6, dotPaint);

    // 3) ㄷ자 브라켓
    if (isStart) {
      // ●──┐
      canvas.drawLine(Offset(axisX, y), Offset(bracketX, y), bracketPaint);
      canvas.drawLine(Offset(bracketX, y), Offset(bracketX, size.height), bracketPaint);
    } else if (isEnd) {
      // ┌──●
      canvas.drawLine(Offset(bracketX, 0), Offset(bracketX, y), bracketPaint);
      canvas.drawLine(Offset(bracketX, y), Offset(axisX, y), bracketPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BracketPainter oldDelegate) {
    return oldDelegate.isStart != isStart ||
        oldDelegate.isEnd != isEnd ||
        oldDelegate.color != color;
  }
}
