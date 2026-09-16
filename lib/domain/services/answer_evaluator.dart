import '../../core/utils/formatters.dart';
import '../models/question.dart';
import '../simulation/simulation_registry.dart';

/// Evalúa respuestas de opción múltiple y numéricas.
class AnswerEvaluator {
  const AnswerEvaluator([this.registry = const SimulationRegistry()]);

  final SimulationRegistry registry;

  /// Calcula la respuesta esperada de una pregunta numérica, en la unidad
  /// que se pide al estudiante.
  double expectedValue(NumericSpec spec) {
    final sim = registry.byId(spec.simulationId);
    final result = sim.evaluate(spec.inputs);
    return result.value(spec.outputKey) / spec.scale;
  }

  AnswerResult evaluateOption(Question question, int index) {
    if (index < 0 || index >= question.options.length) {
      throw RangeError.index(index, question.options, 'index');
    }
    final option = question.options[index];
    return AnswerResult(
      correct: option.correct,
      feedback: option.feedback,
      selectedIndex: index,
    );
  }

  AnswerResult evaluateNumeric(Question question, String rawInput) {
    final spec = question.numeric;
    if (spec == null) {
      throw ArgumentError('La pregunta ${question.id} no es numérica.');
    }
    final expected = expectedValue(spec);
    final expectedText = '${_pretty(expected)} ${spec.unitLabel}';
    final given = parseUserNumber(rawInput);
    if (given == null) {
      return AnswerResult(
        correct: false,
        feedback: 'No se reconoce un número. Escribe solo el valor, por '
            'ejemplo 4.7 o 4,7.',
        expected: expectedText,
        given: rawInput,
      );
    }
    final ok = isWithinTolerance(
      given: given,
      expected: expected,
      tolerancePercent: spec.tolerancePercent,
    );
    return AnswerResult(
      correct: ok,
      feedback: ok
          ? 'Correcto: el valor está dentro de la tolerancia de '
              '±${spec.tolerancePercent.toStringAsFixed(0)} %.'
          : _hint(given, expected),
      expected: expectedText,
      given: rawInput,
    );
  }

  static bool isWithinTolerance({
    required double given,
    required double expected,
    required double tolerancePercent,
  }) {
    if (expected.abs() < 1e-12) return given.abs() < 1e-6;
    final error = (given - expected).abs() / expected.abs() * 100;
    return error <= tolerancePercent;
  }

  static String _hint(double given, double expected) {
    if (expected != 0) {
      final ratio = given / expected;
      for (final factor in const [1000.0, 0.001, 1e6, 1e-6]) {
        if ((ratio / factor - 1).abs() < 0.03) {
          return 'El valor es correcto, pero la unidad no: revisa la '
              'conversión (factor de ${_factorName(factor)}).';
        }
      }
      if ((ratio + 1).abs() < 0.03) {
        return 'La magnitud es correcta, pero el signo no.';
      }
    }
    return 'No coincide con el resultado esperado. Revisa la fórmula y los '
        'datos del enunciado.';
  }

  static String _factorName(double f) {
    if (f == 1000.0 || f == 0.001) return 'mil';
    return 'un millón';
  }

  static String _pretty(double v) {
    final abs = v.abs();
    if (abs >= 100) return v.toStringAsFixed(1);
    if (abs >= 10) return v.toStringAsFixed(2);
    return v.toStringAsFixed(3);
  }
}
