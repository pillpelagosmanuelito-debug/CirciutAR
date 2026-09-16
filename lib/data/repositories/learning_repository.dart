import 'dart:math' as math;

import '../../domain/models/assistant.dart';
import '../../domain/models/competency.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';
import '../../domain/models/practical_case.dart';
import '../../domain/models/question.dart';
import '../../domain/simulation/color_code.dart';
import '../../domain/simulation/standard_values.dart';
import '../../core/utils/formatters.dart';
import '../content/assistant_tree.dart';
import '../content/cases.dart';
import '../content/questions.dart';
import 'component_repository.dart';

/// Identificadores de las evaluaciones.
abstract final class QuizIds {
  static const passive = 'quiz_passive';
  static const active = 'quiz_active';
  static const semiconductors = 'quiz_semiconductors';
  static const sensors = 'quiz_sensors';
  static const symbols = 'quiz_symbols';
  static const integral = 'quiz_integral';

  /// Práctica generada: se renueva en cada intento y no guarda puntaje.
  static const symbolPractice = 'practice_symbols';
  static const colorPractice = 'practice_colors';

  static const graded = [passive, active, semiconductors, sensors, symbols, integral];

  static bool isPractice(String id) =>
      id == symbolPractice || id == colorPractice;
}

/// Evaluaciones, casos prácticos y asistente de selección.
abstract class LearningRepository {
  List<Quiz> quizzes();
  Quiz quiz(String id, {int? seed});
  List<Question> questionsForModule(ModuleId module);
  List<PracticalCase> cases();
  PracticalCase? caseById(String id);
  AssistantNode node(String id);
  String get assistantRoot;
}

class LocalLearningRepository implements LearningRepository {
  const LocalLearningRepository(this.components);

  final ComponentRepository components;

  static const _integralIds = [
    'p_power_choice',
    'p_cap_choice',
    'p_ripple_num',
    'a_opamp_sat',
    'a_reg_num',
    's_led_num',
    's_switch_choice',
    's_bjt_region',
    'n_temp_choice',
    'n_echo_num',
    'id_zener',
    'id_mosfet',
  ];

  @override
  List<Quiz> quizzes() => [for (final id in QuizIds.graded) quiz(id)];

  @override
  Quiz quiz(String id, {int? seed}) {
    switch (id) {
      case QuizIds.passive:
        return Quiz(
          id: id,
          title: 'Componentes pasivos',
          description: 'Potencia, efecto de carga, filtros y bobinas.',
          questions: questionsForModule(ModuleId.passive),
        );
      case QuizIds.active:
        return Quiz(
          id: id,
          title: 'Componentes activos',
          description: 'Ganancia, saturación, regulación y temporización.',
          questions: questionsForModule(ModuleId.active),
        );
      case QuizIds.semiconductors:
        return Quiz(
          id: id,
          title: 'Semiconductores',
          description: 'Diodos, LED, transistores y MOSFET.',
          questions: questionsForModule(ModuleId.semiconductors),
        );
      case QuizIds.sensors:
        return Quiz(
          id: id,
          title: 'Sensores',
          description: 'Luz, temperatura y distancia.',
          questions: questionsForModule(ModuleId.sensors),
        );
      case QuizIds.symbols:
        return Quiz(
          id: id,
          title: 'Identificación de símbolos',
          description: 'Reconoce componentes en un esquema.',
          questions: questionsForModule(ModuleId.assessments),
        );
      case QuizIds.integral:
        return Quiz(
          id: id,
          title: 'Evaluación integral',
          description: 'Las cuatro competencias en una sola prueba.',
          questions: [
            for (final qid in _integralIds)
              questionBank.firstWhere((q) => q.id == qid),
          ],
        );
      case QuizIds.symbolPractice:
        return Quiz(
          id: id,
          title: 'Práctica de símbolos',
          description: 'Diez símbolos al azar del catálogo.',
          questions: generateSymbolPractice(math.Random(seed)),
        );
      case QuizIds.colorPractice:
        return Quiz(
          id: id,
          title: 'Práctica de código de colores',
          description: 'Diez resistores al azar.',
          questions: generateColorPractice(math.Random(seed)),
        );
    }
    throw ArgumentError('Evaluación desconocida: $id');
  }

  @override
  List<Question> questionsForModule(ModuleId module) =>
      questionBank.where((q) => q.module == module).toList();

  @override
  List<PracticalCase> cases() => practicalCases;

  @override
  PracticalCase? caseById(String id) {
    for (final c in practicalCases) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  String get assistantRoot => assistantRootId;

  @override
  AssistantNode node(String id) => assistantTree.firstWhere(
        (n) => n.id == id,
        orElse: () => throw ArgumentError('Nodo desconocido: $id'),
      );

  /// Genera preguntas de identificación a partir de los símbolos del catálogo.
  List<Question> generateSymbolPractice(math.Random random, {int count = 10}) {
    final all = components.all().toList()..shuffle(random);
    final picked = all.take(math.min(count, all.length)).toList();
    return [
      for (final target in picked)
        _symbolQuestion(target, components.all(), random),
    ];
  }

  Question _symbolQuestion(
    ElectronicComponent target,
    List<ElectronicComponent> pool,
    math.Random random,
  ) {
    final others = pool.where((c) => c.symbol != target.symbol).toList()
      ..shuffle(random);
    final options = <AnswerOption>[
      AnswerOption(
        target.name,
        correct: true,
        feedback: 'Correcto: es el símbolo de ${_withArticle(target)}.',
      ),
      for (final o in others.take(3))
        AnswerOption(
          o.name,
          feedback: 'Es el símbolo de ${_withArticle(target)}, no de '
              '${_withArticle(o)}.',
        ),
    ]..shuffle(random);
    return Question(
      id: 'gen_symbol_${target.id}',
      module: ModuleId.assessments,
      competency: Competency.identification,
      componentId: target.id,
      symbol: target.symbol,
      prompt: '¿Qué componente representa este símbolo?',
      explanation: target.symbol.description,
      options: options,
    );
  }

  /// Genera preguntas de lectura del código de colores de 4 bandas.
  List<Question> generateColorPractice(math.Random random, {int count = 10}) {
    final values = e12Between(10, 1000000);
    return List<Question>.generate(count, (i) {
      final ohms = values[random.nextInt(values.length)];
      final bands = ColorCode.encode4(ohms);
      final distractors = <double>{
        ohms * 10,
        ohms / 10,
        _swapDigits(ohms),
        nextE12(ohms * 1.01),
        ohms * 100,
      }..removeWhere((v) => v == ohms || v < 1);
      final choices = [
        ohms,
        ...distractors.take(3),
      ];
      final options = [
        for (final v in choices)
          AnswerOption(
            EngFormat.format(v, 'Ω'),
            correct: v == ohms,
            feedback: v == ohms
                ? 'Correcto: ${_bandNames(bands)}.'
                : 'Las bandas ${_bandNames(bands)} indican '
                    '${EngFormat.format(ohms, 'Ω')}.',
          ),
      ]..shuffle(random);
      return Question(
        id: 'gen_color_$i',
        module: ModuleId.assessments,
        competency: Competency.identification,
        componentId: 'resistor',
        bands: bands,
        prompt: '¿Qué valor tiene este resistor? (bandas: ${_bandNames(bands)})',
        explanation: 'Primera y segunda banda: cifras. Tercera: número de '
            'ceros. Cuarta: tolerancia.',
        options: options,
      );
    });
  }

  static String _bandNames(List<BandColor> bands) =>
      bands.map((b) => b.label.toLowerCase()).join(', ');

  static double _swapDigits(double ohms) {
    final bands = ColorCode.encode4(ohms);
    final swapped = [bands[1], bands[0], bands[2], bands[3]];
    if (swapped[0] == BandColor.black) return ohms * 2;
    return ColorCode.decode(swapped).ohms;
  }

  static String _withArticle(ElectronicComponent c) {
    const feminine = {'ldr'};
    final article = feminine.contains(c.id) ? 'la' : 'el';
    final name = c.name;
    final keepCase = name.length > 1 && name[1] == name[1].toUpperCase();
    final text = keepCase ? name : name[0].toLowerCase() + name.substring(1);
    return '$article $text';
  }
}
