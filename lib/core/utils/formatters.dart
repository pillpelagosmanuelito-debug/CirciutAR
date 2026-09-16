import 'dart:math' as math;

/// Formato de magnitudes con prefijos de ingeniería (p, n, µ, m, k, M, G).
abstract final class EngFormat {
  static const _prefixes = <int, String>{
    -12: 'p',
    -9: 'n',
    -6: 'µ',
    -3: 'm',
    0: '',
    3: 'k',
    6: 'M',
    9: 'G',
  };

  /// Formatea [value] con tres cifras significativas y el prefijo adecuado.
  ///
  /// `EngFormat.format(0.0047, 'F')` devuelve `4.70 mF`.
  static String format(double value, String unit, {int significant = 3}) {
    if (value.isNaN) return '—';
    if (value.isInfinite) return value > 0 ? '∞ $unit' : '−∞ $unit';
    final sep = unit.isEmpty ? '' : ' ';
    if (value == 0) return '0$sep$unit';

    final abs = value.abs();
    final exp = (math.log(abs) / math.ln10).floor();
    var eng = (exp / 3).floor() * 3;
    eng = eng.clamp(-12, 9).toInt();
    var scaled = abs / math.pow(10, eng);

    // Corrige redondeos como 999.9 → 1.00 k.
    final digitsBefore = scaled >= 100 ? 3 : (scaled >= 10 ? 2 : 1);
    var decimals = math.max(0, significant - digitsBefore);
    var text = scaled.toStringAsFixed(decimals);
    if (double.parse(text) >= 1000 && eng < 9) {
      eng += 3;
      scaled = abs / math.pow(10, eng);
      decimals = math.max(0, significant - 1);
      text = scaled.toStringAsFixed(decimals);
    }
    final sign = value < 0 ? '−' : '';
    return '$sign$text$sep${_prefixes[eng]}$unit';
  }

  /// Formatea un número sin prefijos, con [decimals] decimales.
  static String plain(double value, String unit, {int decimals = 2}) {
    if (value.isNaN) return '—';
    final sep = unit.isEmpty || unit == '%' ? '' : ' ';
    final sign = value < 0 ? '−' : '';
    return '$sign${value.abs().toStringAsFixed(decimals)}$sep$unit';
  }

  /// Formato compacto para valores de parámetros de entrada.
  static String parameter(double value, String unit, {int decimals = 2}) {
    if (unit == 'Ω' || unit == 'Hz') return format(value, unit);
    return plain(value, unit, decimals: decimals);
  }
}

/// Convierte texto escrito por el estudiante en número.
///
/// Acepta coma o punto decimal y los sufijos k y M (por ejemplo, «4,7k»).
double? parseUserNumber(String raw) {
  var text = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (text.isEmpty) return null;
  text = text.replaceAll('−', '-');
  var factor = 1.0;
  if (text.endsWith('k') || text.endsWith('K')) {
    factor = 1e3;
    text = text.substring(0, text.length - 1);
  } else if (text.endsWith('M')) {
    factor = 1e6;
    text = text.substring(0, text.length - 1);
  }
  final value = double.tryParse(text);
  if (value == null) return null;
  return value * factor;
}
