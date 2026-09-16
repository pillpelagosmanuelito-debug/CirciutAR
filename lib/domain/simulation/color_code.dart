import 'dart:math' as math;

/// Colores del código de resistores (IEC 60062).
enum BandColor {
  black('Negro', 0xFF1B1B1B, digit: 0, multiplierExp: 0),
  brown('Marrón', 0xFF7B4A2A, digit: 1, multiplierExp: 1, tolerance: 1),
  red('Rojo', 0xFFD32F2F, digit: 2, multiplierExp: 2, tolerance: 2),
  orange('Naranja', 0xFFF57C00, digit: 3, multiplierExp: 3),
  yellow('Amarillo', 0xFFFBC02D, digit: 4, multiplierExp: 4),
  green('Verde', 0xFF388E3C, digit: 5, multiplierExp: 5, tolerance: 0.5),
  blue('Azul', 0xFF1976D2, digit: 6, multiplierExp: 6, tolerance: 0.25),
  violet('Violeta', 0xFF7B1FA2, digit: 7, tolerance: 0.1),
  grey('Gris', 0xFF757575, digit: 8, tolerance: 0.05),
  white('Blanco', 0xFFF5F5F5, digit: 9),
  gold('Dorado', 0xFFC9A227, multiplierExp: -1, tolerance: 5),
  silver('Plateado', 0xFFB0B7BD, multiplierExp: -2, tolerance: 10);

  const BandColor(
    this.label,
    this.argb, {
    this.digit,
    this.multiplierExp,
    this.tolerance,
  });

  final String label;
  final int argb;
  final int? digit;

  /// Exponente de la potencia de diez que representa como multiplicador.
  final int? multiplierExp;

  /// Tolerancia en porcentaje.
  final double? tolerance;

  bool get isDigit => digit != null;
  bool get isMultiplier => multiplierExp != null;
  bool get isTolerance => tolerance != null;

  static List<BandColor> get digits =>
      values.where((c) => c.isDigit).toList();
  static List<BandColor> get multipliers =>
      values.where((c) => c.isMultiplier).toList();
  static List<BandColor> get tolerances =>
      values.where((c) => c.isTolerance).toList();
}

/// Resultado de leer las bandas de un resistor.
class ResistorReading {
  const ResistorReading({required this.ohms, required this.tolerance});

  final double ohms;
  final double tolerance;

  double get minOhms => ohms * (1 - tolerance / 100);
  double get maxOhms => ohms * (1 + tolerance / 100);
}

/// Codificación y decodificación del código de colores.
abstract final class ColorCode {
  /// Decodifica 4 bandas (2 dígitos) o 5 bandas (3 dígitos).
  static ResistorReading decode(List<BandColor> bands) {
    if (bands.length != 4 && bands.length != 5) {
      throw ArgumentError('Se esperan 4 o 5 bandas.');
    }
    final digitCount = bands.length - 2;
    var significant = 0;
    for (var i = 0; i < digitCount; i++) {
      final d = bands[i].digit;
      if (d == null) {
        throw ArgumentError('${bands[i].label} no es un color de dígito.');
      }
      significant = significant * 10 + d;
    }
    final mult = bands[digitCount].multiplierExp;
    if (mult == null) {
      throw ArgumentError(
        '${bands[digitCount].label} no es un color multiplicador.',
      );
    }
    final tol = bands.last.tolerance;
    if (tol == null) {
      throw ArgumentError('${bands.last.label} no es un color de tolerancia.');
    }
    final ohms = significant * math.pow(10, mult).toDouble();
    return ResistorReading(ohms: _clean(ohms), tolerance: tol);
  }

  /// Codifica un valor en 4 bandas (dos cifras significativas).
  static List<BandColor> encode4(double ohms, {BandColor tolerance = BandColor.gold}) {
    if (ohms < 0.1) throw ArgumentError('Valor fuera de rango.');
    var exp = (math.log(ohms) / math.ln10).floor() - 1;
    var significant = (ohms / math.pow(10, exp)).round();
    if (significant >= 100) {
      significant = (significant / 10).round();
      exp += 1;
    }
    final first = significant ~/ 10;
    final second = significant % 10;
    final multiplier = BandColor.values.firstWhere(
      (c) => c.multiplierExp == exp,
      orElse: () => throw ArgumentError('Multiplicador fuera de rango.'),
    );
    return [
      BandColor.values.firstWhere((c) => c.digit == first),
      BandColor.values.firstWhere((c) => c.digit == second),
      multiplier,
      tolerance,
    ];
  }

  static double _clean(double v) => double.parse(v.toStringAsPrecision(6));
}
