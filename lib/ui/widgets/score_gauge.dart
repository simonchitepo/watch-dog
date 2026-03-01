import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/watchdog_theme.dart';

class ScoreGauge extends StatelessWidget {
  /// 0..1
  final double score;
  final String label;
  final Color color;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = score.clamp(0.0, 1.0);
    final wd = context.wd;

    return SizedBox(
      width: 160,
      height: 130,
      child: CustomPaint(
        painter: _GaugePainter(
          value: s,
          color: color,
          border: wd.border.withOpacity(0.35),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(s * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: wd.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color border;

  _GaugePainter({required this.value, required this.color, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = math.min(size.width, size.height) * 0.72;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = border;

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = color;

    const start = math.pi; // 180deg
    const sweep = math.pi; // 180deg

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep * value,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
