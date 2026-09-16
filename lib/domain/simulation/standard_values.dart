import 'dart:math' as math;

/// Serie E12 de valores normalizados (tolerancia 10 %).
const List<double> e12Series = [
  1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2, //
];

/// Tensiones nominales comerciales de capacitores electrolíticos.
const List<double> electrolyticVoltageRatings = [
  6.3, 10, 16, 25, 35, 50, 63, 100, //
];

/// Devuelve el valor E12 igual o inmediatamente superior a [value].
///
/// Se redondea hacia arriba porque, al limitar corriente, un valor mayor es
/// el lado seguro.
double nextE12(double value) {
  if (value <= 0) return e12Series.first;
  final decade = (math.log(value) / math.ln10).floor();
  final base = math.pow(10, decade).toDouble();
  final mantissa = value / base;
  for (final e in e12Series) {
    if (e >= mantissa - 1e-9) return _round(e * base);
  }
  return _round(10 * base);
}

/// Devuelve la tensión nominal comercial igual o superior a [value].
double nextVoltageRating(double value) {
  for (final v in electrolyticVoltageRatings) {
    if (v >= value - 1e-9) return v;
  }
  return electrolyticVoltageRatings.last;
}

/// Todos los valores E12 entre [min] y [max], ambos incluidos.
List<double> e12Between(double min, double max) {
  final result = <double>[];
  var decade = (math.log(min) / math.ln10).floor();
  while (true) {
    final base = math.pow(10, decade).toDouble();
    if (base > max) break;
    for (final e in e12Series) {
      final v = _round(e * base);
      if (v >= min - 1e-9 && v <= max + 1e-9) result.add(v);
    }
    decade++;
  }
  return result;
}

double _round(double v) => double.parse(v.toStringAsPrecision(6));
