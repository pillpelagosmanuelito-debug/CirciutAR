import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/simulation/simulation.dart';

/// Gráfico de línea liviano para las curvas de las simulaciones.
///
/// Se dibuja con `CustomPainter` para no depender de librerías externas.
class CurveChart extends StatelessWidget {
  const CurveChart({super.key, required this.curve, this.height = 220});

  final SimCurve curve;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(curve.title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Eje vertical: ${curve.yLabel} · Eje horizontal: ${curve.xLabel}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _CurvePainter(
              curve: curve,
              line: theme.colorScheme.primary,
              marker: theme.colorScheme.error,
              grid: theme.colorScheme.outlineVariant,
              text: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.curve,
    required this.line,
    required this.marker,
    required this.grid,
    required this.text,
  });

  final SimCurve curve;
  final Color line;
  final Color marker;
  final Color grid;
  final Color text;

  static const double _left = 48;
  static const double _bottom = 22;
  static const double _top = 8;
  static const double _right = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = curve.points;
    if (pts.length < 2) return;

    var minX = pts.map((p) => p.x).reduce(math.min);
    var maxX = pts.map((p) => p.x).reduce(math.max);
    var minY = pts.map((p) => p.y).reduce(math.min);
    var maxY = pts.map((p) => p.y).reduce(math.max);
    final m = curve.marker;
    if (m != null) {
      minX = math.min(minX, m.x);
      maxX = math.max(maxX, m.x);
      minY = math.min(minY, m.y);
      maxY = math.max(maxY, m.y);
    }
    if (minY > 0) minY = 0;
    if (maxY == minY) maxY = minY + 1;
    if (maxX == minX) maxX = minX + 1;
    final padY = (maxY - minY) * 0.08;
    maxY += padY;
    if (minY < 0) minY -= padY;

    final plot = Rect.fromLTRB(
      _left,
      _top,
      size.width - _right,
      size.height - _bottom,
    );

    Offset map(double x, double y) => Offset(
          plot.left + (x - minX) / (maxX - minX) * plot.width,
          plot.bottom - (y - minY) / (maxY - minY) * plot.height,
        );

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final value = maxY - (maxY - minY) * i / 4;
      _label(canvas, _fmt(value), Offset(plot.left - 6, y), alignRight: true);
    }
    for (var i = 0; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      final value = minX + (maxX - minX) * i / 4;
      _label(canvas, _fmt(value), Offset(x, plot.bottom + 10));
    }

    if (minY < 0 && maxY > 0) {
      final zero = map(minX, 0).dy;
      canvas.drawLine(
        Offset(plot.left, zero),
        Offset(plot.right, zero),
        Paint()
          ..color = text.withAlpha(120)
          ..strokeWidth = 1.2,
      );
    }

    final path = Path();
    final first = map(pts.first.x, pts.first.y);
    path.moveTo(first.dx, first.dy);
    for (final p in pts.skip(1)) {
      final o = map(p.x, p.y);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    if (m != null) {
      final o = map(m.x, m.y);
      canvas.drawCircle(o, 7, Paint()..color = marker.withAlpha(60));
      canvas.drawCircle(o, 4.5, Paint()..color = marker);
    }
  }

  void _label(Canvas canvas, String value, Offset at, {bool alignRight = false}) {
    final tp = TextPainter(
      text: TextSpan(text: value, style: TextStyle(color: text, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? at.dx - tp.width : at.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  static String _fmt(double v) {
    final a = v.abs();
    if (a == 0) return '0';
    if (a >= 10000) return '${(v / 1000).toStringAsFixed(0)}k';
    if (a >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (a >= 100) return v.toStringAsFixed(0);
    if (a >= 10) return v.toStringAsFixed(1);
    if (a >= 1) return v.toStringAsFixed(2);
    return v.toStringAsFixed(3);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.curve != curve ||
      oldDelegate.line != line ||
      oldDelegate.marker != marker;
}
