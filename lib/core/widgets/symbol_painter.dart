import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/electronic_component.dart';

/// Dibuja el símbolo esquemático de un componente.
///
/// Los símbolos se trazan con vectores (sin imágenes), así que se ven
/// nítidos en cualquier pantalla y respetan el tema claro u oscuro.
class ComponentSymbol extends StatelessWidget {
  const ComponentSymbol(
    this.type, {
    super.key,
    this.width = 120,
    this.height = 80,
    this.color,
  });

  final SymbolType type;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: type.description,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: SymbolPainter(
            type,
            color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class SymbolPainter extends CustomPainter {
  SymbolPainter(this.type, this.color);

  final SymbolType type;
  final Color color;

  static const double _w = 120;
  static const double _h = 80;

  late Paint _stroke;
  late Paint _fill;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _w, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);

    _stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case SymbolType.resistor:
        _resistor(canvas);
      case SymbolType.potentiometer:
        _resistor(canvas);
        _arrow(canvas, const Offset(60, 76), const Offset(60, 53));
      case SymbolType.ldr:
        _resistor(canvas);
        _arrow(canvas, const Offset(32, 6), const Offset(43, 23));
        _arrow(canvas, const Offset(48, 6), const Offset(59, 23));
      case SymbolType.ntc:
        _resistor(canvas);
        _line(canvas, const Offset(20, 66), const Offset(30, 66));
        _line(canvas, const Offset(30, 66), const Offset(90, 14));
        _text(canvas, '−t°', const Offset(98, 12), 13);
      case SymbolType.capacitorCeramic:
        _line(canvas, const Offset(0, 40), const Offset(54, 40));
        _line(canvas, const Offset(54, 18), const Offset(54, 62));
        _line(canvas, const Offset(66, 18), const Offset(66, 62));
        _line(canvas, const Offset(66, 40), const Offset(120, 40));
      case SymbolType.capacitorElectrolytic:
        _electrolytic(canvas);
      case SymbolType.inductor:
        _line(canvas, const Offset(0, 40), const Offset(28, 40));
        for (var i = 0; i < 4; i++) {
          canvas.drawArc(
            Rect.fromLTWH(28 + 16.0 * i, 32, 16, 16),
            math.pi,
            math.pi,
            false,
            _stroke,
          );
        }
        _line(canvas, const Offset(92, 40), const Offset(120, 40));
      case SymbolType.diode:
        _diode(canvas);
        _line(canvas, const Offset(75, 24), const Offset(75, 56));
      case SymbolType.zener:
        _diode(canvas);
        _zenerBar(canvas);
      case SymbolType.led:
        _diode(canvas);
        _line(canvas, const Offset(75, 24), const Offset(75, 56));
        _arrow(canvas, const Offset(58, 22), const Offset(70, 6));
        _arrow(canvas, const Offset(70, 24), const Offset(82, 8));
      case SymbolType.bjtNpn:
        _bjt(canvas);
      case SymbolType.mosfetN:
        _mosfet(canvas);
      case SymbolType.opAmp:
        _opAmp(canvas);
      case SymbolType.regulator:
        _regulator(canvas);
      case SymbolType.timer555:
        _timer(canvas);
      case SymbolType.tempSensorIc:
        _tempSensor(canvas);
      case SymbolType.ultrasonic:
        _ultrasonic(canvas);
    }
    canvas.restore();
  }

  void _line(Canvas c, Offset a, Offset b) => c.drawLine(a, b, _stroke);

  void _arrow(Canvas c, Offset from, Offset to) {
    _line(c, from, to);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const len = 7.0;
    const spread = 0.45;
    final p1 = to -
        Offset(math.cos(angle - spread), math.sin(angle - spread)) * len;
    final p2 = to -
        Offset(math.cos(angle + spread), math.sin(angle + spread)) * len;
    final head = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    c.drawPath(head, _fill);
  }

  void _text(Canvas c, String text, Offset center, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _resistor(Canvas c) {
    _line(c, const Offset(0, 40), const Offset(30, 40));
    final zig = Path()..moveTo(30, 40);
    const pts = [
      Offset(35, 30),
      Offset(45, 50),
      Offset(55, 30),
      Offset(65, 50),
      Offset(75, 30),
      Offset(85, 50),
      Offset(90, 40),
    ];
    for (final p in pts) {
      zig.lineTo(p.dx, p.dy);
    }
    c.drawPath(zig, _stroke);
    _line(c, const Offset(90, 40), const Offset(120, 40));
  }

  void _diode(Canvas c) {
    _line(c, const Offset(0, 40), const Offset(45, 40));
    final tri = Path()
      ..moveTo(45, 24)
      ..lineTo(45, 56)
      ..lineTo(74, 40)
      ..close();
    c.drawPath(tri, _stroke);
    _line(c, const Offset(75, 40), const Offset(120, 40));
  }

  void _electrolytic(Canvas c) {
    _line(c, const Offset(0, 40), const Offset(54, 40));
    _line(c, const Offset(54, 18), const Offset(54, 62));
    final curve = Path()
      ..moveTo(74, 18)
      ..quadraticBezierTo(60, 40, 74, 62);
    c.drawPath(curve, _stroke);
    _line(c, const Offset(67, 40), const Offset(120, 40));
    _text(c, '+', const Offset(44, 14), 16);
  }

  void _zenerBar(Canvas c) {
    final bar = Path()
      ..moveTo(81, 20)
      ..lineTo(75, 24)
      ..lineTo(75, 56)
      ..lineTo(69, 60);
    c.drawPath(bar, _stroke);
  }

  void _bjt(Canvas c) {
    c.drawCircle(const Offset(68, 40), 28, _stroke);
    _line(c, const Offset(0, 40), const Offset(52, 40));
    _line(c, const Offset(52, 26), const Offset(52, 54));
    _line(c, const Offset(52, 33), const Offset(80, 18));
    _line(c, const Offset(80, 18), const Offset(80, 0));
    _arrow(c, const Offset(52, 47), const Offset(79, 62));
    _line(c, const Offset(80, 62), const Offset(80, 80));
    _text(c, 'B', const Offset(20, 30), 11);
    _text(c, 'C', const Offset(92, 8), 11);
    _text(c, 'E', const Offset(92, 72), 11);
  }

  void _mosfet(Canvas c) {
    _line(c, const Offset(0, 56), const Offset(40, 56));
    _line(c, const Offset(40, 22), const Offset(40, 58));
    _line(c, const Offset(48, 18), const Offset(48, 28));
    _line(c, const Offset(48, 35), const Offset(48, 45));
    _line(c, const Offset(48, 52), const Offset(48, 62));
    _line(c, const Offset(48, 23), const Offset(80, 23));
    _line(c, const Offset(80, 23), const Offset(80, 0));
    _line(c, const Offset(48, 57), const Offset(80, 57));
    _line(c, const Offset(80, 57), const Offset(80, 80));
    _arrow(c, const Offset(80, 40), const Offset(50, 40));
    _line(c, const Offset(80, 40), const Offset(80, 57));
    _text(c, 'G', const Offset(14, 46), 11);
    _text(c, 'D', const Offset(92, 8), 11);
    _text(c, 'S', const Offset(92, 72), 11);
  }

  void _opAmp(Canvas c) {
    final tri = Path()
      ..moveTo(30, 6)
      ..lineTo(30, 74)
      ..lineTo(96, 40)
      ..close();
    c.drawPath(tri, _stroke);
    _line(c, const Offset(0, 24), const Offset(30, 24));
    _line(c, const Offset(0, 56), const Offset(30, 56));
    _line(c, const Offset(96, 40), const Offset(120, 40));
    _text(c, '−', const Offset(39, 24), 16);
    _text(c, '+', const Offset(39, 56), 16);
  }

  void _regulator(Canvas c) {
    c.drawRect(const Rect.fromLTWH(34, 16, 52, 40), _stroke);
    _line(c, const Offset(0, 32), const Offset(34, 32));
    _line(c, const Offset(86, 32), const Offset(120, 32));
    _line(c, const Offset(60, 56), const Offset(60, 80));
    _text(c, 'REG', const Offset(60, 36), 12);
    _text(c, 'IN', const Offset(14, 22), 10);
    _text(c, 'OUT', const Offset(104, 22), 10);
    _text(c, 'GND', const Offset(80, 70), 10);
  }

  void _timer(Canvas c) {
    c.drawRect(const Rect.fromLTWH(34, 6, 52, 68), _stroke);
    for (var i = 0; i < 4; i++) {
      final y = 16.0 + i * 16;
      _line(c, Offset(14, y), Offset(34, y));
      _line(c, Offset(86, y), Offset(106, y));
      _text(c, '${i + 1}', Offset(8, y), 9);
      _text(c, '${8 - i}', Offset(112, y), 9);
    }
    _text(c, '555', const Offset(60, 40), 15);
  }

  void _tempSensor(Canvas c) {
    c.drawRect(const Rect.fromLTWH(32, 10, 56, 38), _stroke);
    _text(c, 'LM35', const Offset(60, 29), 13);
    for (final x in const [44.0, 60.0, 76.0]) {
      _line(c, Offset(x, 48), Offset(x, 68));
    }
    _text(c, '+Vs', const Offset(40, 75), 9);
    _text(c, 'Vo', const Offset(60, 75), 9);
    _text(c, 'GND', const Offset(82, 75), 9);
  }

  void _ultrasonic(Canvas c) {
    c.drawCircle(const Offset(38, 48), 15, _stroke);
    c.drawCircle(const Offset(82, 48), 15, _stroke);
    _text(c, 'T', const Offset(38, 48), 13);
    _text(c, 'R', const Offset(82, 48), 13);
    for (final r in const [22.0, 29.0]) {
      c.drawArc(
        Rect.fromCircle(center: const Offset(38, 48), radius: r),
        -math.pi * 3 / 4,
        math.pi / 2,
        false,
        _stroke,
      );
      c.drawArc(
        Rect.fromCircle(center: const Offset(82, 48), radius: r),
        -math.pi * 3 / 4,
        math.pi / 2,
        false,
        _stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SymbolPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
