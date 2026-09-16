import '../simulation/color_code.dart';
import 'competency.dart';
import 'electronic_component.dart';
import 'learning_module.dart';

enum QuestionType { multipleChoice, numeric }

/// Opción de respuesta con retroalimentación propia.
///
/// Cada distractor explica por qué no es correcto: así la pregunta enseña
/// a seleccionar y no solo a memorizar.
class AnswerOption {
  const AnswerOption(this.text, {this.correct = false, required this.feedback});

  final String text;
  final bool correct;
  final String feedback;
}

/// Especificación de una respuesta numérica.
///
/// La respuesta no está escrita: se calcula con la misma simulación que usa
/// el estudiante, de modo que contenido y laboratorio nunca se contradicen.
class NumericSpec {
  const NumericSpec({
    required this.simulationId,
    required this.inputs,
    required this.outputKey,
    required this.unitLabel,
    this.scale = 1,
    this.tolerancePercent = 2,
  });

  final String simulationId;
  final Map<String, double> inputs;
  final String outputKey;

  /// Unidad en la que el estudiante debe responder (por ejemplo, «mA»).
  final String unitLabel;

  /// Factor para pasar del valor SI a la unidad pedida (1e-3 para mA).
  final double scale;

  final double tolerancePercent;
}

class Question {
  const Question({
    required this.id,
    required this.module,
    required this.competency,
    required this.prompt,
    required this.explanation,
    this.componentId,
    this.symbol,
    this.bands,
    this.options = const [],
    this.numeric,
  }) : type = numeric == null
            ? QuestionType.multipleChoice
            : QuestionType.numeric;

  final String id;
  final ModuleId module;
  final Competency competency;
  final String prompt;

  /// Explicación general que se muestra después de responder.
  final String explanation;

  /// Componente relacionado: se usa para recomendar repaso.
  final String? componentId;

  /// Símbolo que se dibuja junto al enunciado (identificación visual).
  final SymbolType? symbol;

  /// Bandas de un resistor que se dibujan junto al enunciado.
  final List<BandColor>? bands;

  final List<AnswerOption> options;
  final NumericSpec? numeric;
  final QuestionType type;
}

/// Resultado de evaluar una respuesta.
class AnswerResult {
  const AnswerResult({
    required this.correct,
    required this.feedback,
    this.expected,
    this.selectedIndex,
    this.given,
  });

  final bool correct;
  final String feedback;

  /// Respuesta esperada en texto (para preguntas numéricas).
  final String? expected;

  final int? selectedIndex;
  final String? given;
}

/// Evaluación del módulo 6.
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final List<Question> questions;
}
