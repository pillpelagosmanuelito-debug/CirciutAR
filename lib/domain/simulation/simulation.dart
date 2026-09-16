import 'dart:math' as math;

import '../models/competency.dart';

/// Parámetro ajustable de una simulación.
///
/// Los valores se expresan en la unidad de presentación indicada en [unit]
/// (por ejemplo, µF o mA); cada simulación convierte internamente a SI.
class SimParameter {
  const SimParameter({
    required this.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.defaultValue,
    this.logarithmic = false,
    this.decimals = 2,
    this.optionLabels,
  });

  final String key;
  final String label;
  final String unit;
  final double min;
  final double max;
  final double defaultValue;

  /// Si es verdadero, el control deslizante recorre décadas.
  final bool logarithmic;

  final int decimals;

  /// Si existe, el parámetro es discreto: el valor es el índice (0, 1, 2…).
  final List<String>? optionLabels;

  bool get isDiscrete => optionLabels != null;

  double clamp(double value) => value.clamp(min, max).toDouble();

  /// Convierte un valor a la posición normalizada del control (0 a 1).
  double toSliderPosition(double value) {
    final v = clamp(value);
    if (logarithmic) {
      final lmin = math.log(min);
      final lmax = math.log(max);
      return (math.log(v) - lmin) / (lmax - lmin);
    }
    return (v - min) / (max - min);
  }

  /// Convierte una posición normalizada (0 a 1) al valor del parámetro.
  double fromSliderPosition(double position) {
    final p = position.clamp(0.0, 1.0).toDouble();
    double value;
    if (logarithmic) {
      final lmin = math.log(min);
      final lmax = math.log(max);
      value = math.exp(lmin + (lmax - lmin) * p);
    } else {
      value = min + (max - min) * p;
    }
    if (isDiscrete) value = value.roundToDouble();
    return clamp(value);
  }
}

/// Magnitud calculada por una simulación, siempre en unidades SI.
class SimOutput {
  const SimOutput({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    this.plain = false,
  });

  final String key;
  final String label;
  final double value;

  /// Unidad SI (V, A, Ω, W, s, Hz, %, °C…).
  final String unit;

  /// Si es verdadero, se muestra sin prefijos de ingeniería.
  final bool plain;
}

enum MessageLevel { info, success, warning, danger }

/// Observación didáctica generada por la simulación.
class SimMessage {
  const SimMessage(this.level, this.text);

  final MessageLevel level;
  final String text;
}

class CurvePoint {
  const CurvePoint(this.x, this.y);

  final double x;
  final double y;
}

/// Curva que se dibuja junto a los resultados.
class SimCurve {
  const SimCurve({
    required this.title,
    required this.xLabel,
    required this.yLabel,
    required this.points,
    this.marker,
  });

  final String title;
  final String xLabel;
  final String yLabel;
  final List<CurvePoint> points;

  /// Punto de operación actual.
  final CurvePoint? marker;
}

class SimResult {
  const SimResult({
    required this.outputs,
    required this.messages,
    this.state,
    this.curve,
  });

  /// Estado o región de operación, en palabras (por ejemplo, «Saturación»).
  final String? state;
  final List<SimOutput> outputs;
  final List<SimMessage> messages;
  final SimCurve? curve;

  SimOutput output(String key) => outputs.firstWhere(
        (o) => o.key == key,
        orElse: () => throw ArgumentError('Salida desconocida: $key'),
      );

  double value(String key) => output(key).value;
}

/// Simulación simple de un componente en su circuito típico.
///
/// Son modelos cerrados y deterministas: el objetivo es mostrar por qué se
/// elige un componente, no reemplazar a un simulador SPICE.
abstract class ComponentSimulation {
  const ComponentSimulation();

  String get id;
  String get title;

  /// Circuito que se simula, descrito en palabras.
  String get circuit;

  /// Qué debe descubrir el estudiante.
  String get learningGoal;

  /// Modelo y supuestos declarados.
  String get assumptions;

  List<SimParameter> get parameters;

  /// Preguntas para guiar la experimentación.
  List<String> get guidingQuestions;

  Competency get competency => Competency.functional;

  SimResult evaluate(Map<String, double> inputs);

  Map<String, double> get defaults => {
        for (final p in parameters) p.key: p.defaultValue,
      };

  /// Lee un parámetro aplicando su valor por defecto y sus límites.
  double read(Map<String, double> inputs, String key) {
    final p = parameters.firstWhere(
      (e) => e.key == key,
      orElse: () => throw ArgumentError('Parámetro desconocido: $key'),
    );
    return p.clamp(inputs[key] ?? p.defaultValue);
  }
}

/// Genera [count] valores equiespaciados entre [from] y [to].
List<double> linspace(double from, double to, int count) {
  if (count < 2) return [from];
  final step = (to - from) / (count - 1);
  return List<double>.generate(count, (i) => from + step * i);
}

/// Genera [count] valores equiespaciados en escala logarítmica.
List<double> logspace(double from, double to, int count) {
  final a = math.log(from);
  final b = math.log(to);
  return linspace(a, b, count).map(math.exp).toList();
}
