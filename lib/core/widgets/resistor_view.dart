import 'package:flutter/material.dart';

import '../../domain/simulation/color_code.dart';

/// Dibujo de un resistor de montaje por orificio con sus bandas de color.
class ResistorView extends StatelessWidget {
  const ResistorView({super.key, required this.bands, this.height = 70});

  final List<BandColor> bands;
  final double height;

  @override
  Widget build(BuildContext context) {
    final names = bands.map((b) => b.label.toLowerCase()).join(', ');
    return Semantics(
      label: 'Resistor con bandas $names',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ResistorPainter(
            bands,
            Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _ResistorPainter extends CustomPainter {
  _ResistorPainter(this.bands, this.outline);

  final List<BandColor> bands;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final bodyW = size.width * 0.55;
    final bodyH = size.height * 0.62;
    final left = (size.width - bodyW) / 2;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, midY - bodyH / 2, bodyW, bodyH),
      Radius.circular(bodyH / 2.4),
    );

    final lead = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(8, midY), Offset(left, midY), lead);
    canvas.drawLine(
      Offset(left + bodyW, midY),
      Offset(size.width - 8, midY),
      lead,
    );

    canvas.drawRRect(body, Paint()..color = const Color(0xFFE8D2A6));
    canvas.save();
    canvas.clipRRect(body);

    final bandW = bodyW * 0.07;
    final count = bands.length;
    // Las bandas de valor van juntas; la de tolerancia, separada a la derecha.
    final start = left + bodyW * 0.16;
    final valueSpan = bodyW * 0.48;
    final step = count > 1 ? valueSpan / (count - 2) : 0.0;
    for (var i = 0; i < count; i++) {
      final isLast = i == count - 1;
      final x = isLast ? left + bodyW * 0.80 : start + step * i;
      final rect = Rect.fromLTWH(x, midY - bodyH / 2, bandW, bodyH);
      canvas.drawRect(rect, Paint()..color = Color(bands[i].argb));
      canvas.drawRect(
        rect,
        Paint()
          ..color = outline.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      body,
      Paint()
        ..color = outline.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _ResistorPainter oldDelegate) =>
      oldDelegate.bands != bands || oldDelegate.outline != outline;
}
