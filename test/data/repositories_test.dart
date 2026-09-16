import 'dart:math' as math;

import 'package:circuitar/data/repositories/component_repository.dart';
import 'package:circuitar/data/repositories/learning_repository.dart';
import 'package:circuitar/data/repositories/progress_repository.dart';
import 'package:circuitar/domain/models/competency.dart';
import 'package:circuitar/domain/models/learning_module.dart';
import 'package:circuitar/domain/models/progress.dart';
import 'package:circuitar/domain/models/question.dart';
import 'package:circuitar/domain/services/answer_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const components = LocalComponentRepository();
  const learning = LocalLearningRepository(components);

  group('Repositorio de componentes', () {
    test('la búsqueda ignora tildes y mayúsculas', () {
      final byName = components.search('CERAMICO');
      expect(byName.map((c) => c.id), contains('capacitor_ceramic'));
      final byCode = components.search('1n4007');
      expect(byCode.map((c) => c.id), contains('diode_rectifier'));
      expect(components.search('   '), hasLength(components.all().length));
      expect(components.search('xyz123'), isEmpty);
    });

    test('la búsqueda respeta el filtro de categoría', () {
      final result =
          components.search('', category: ComponentCategory.sensor);
      expect(result, isNotEmpty);
      expect(result.every((c) => c.category == ComponentCategory.sensor),
          isTrue);
    });

    test('la comparación curada se orienta según el orden elegido', () {
      final straight = components.compare('bjt_npn', 'mosfet_n');
      final reversed = components.compare('mosfet_n', 'bjt_npn');
      expect(straight.isCurated, isTrue);
      expect(straight.rows.first.a, 'Corriente de base');
      expect(reversed.rows.first.a, 'Tensión de compuerta');
      expect(straight.chooseLeftWhen, reversed.chooseRightWhen);
    });

    test('la comparación genérica usa los rasgos estándar', () {
      final view = components.compare('ldr', 'opamp');
      expect(view.isCurated, isFalse);
      expect(view.rows, hasLength(6));
    });

    test('comparar un identificador desconocido falla', () {
      expect(() => components.compare('x', 'led'), throwsArgumentError);
    });

    test('normalize quita tildes', () {
      expect(LocalComponentRepository.normalize(' Ñandú Óhmico '),
          'nandu ohmico');
    });
  });

  group('Repositorio de aprendizaje', () {
    test('todas las evaluaciones calificadas tienen preguntas', () {
      final quizzes = learning.quizzes();
      expect(quizzes, hasLength(QuizIds.graded.length));
      for (final q in quizzes) {
        expect(q.questions, isNotEmpty, reason: q.id);
      }
      expect(learning.quiz(QuizIds.integral).questions, hasLength(12));
    });

    test('una evaluación desconocida falla', () {
      expect(() => learning.quiz('nada'), throwsArgumentError);
    });

    test('la práctica de símbolos es reproducible con semilla', () {
      final a = learning.generateSymbolPractice(math.Random(7));
      final b = learning.generateSymbolPractice(math.Random(7));
      expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
      expect(a, hasLength(10));
      for (final q in a) {
        expect(q.symbol, isNotNull);
        expect(q.options.where((o) => o.correct), hasLength(1));
        expect(q.options, hasLength(4));
        expect(q.competency, Competency.identification);
      }
    });

    test('la práctica de colores tiene una respuesta correcta y dibujo', () {
      final questions = learning.generateColorPractice(math.Random(3));
      expect(questions, hasLength(10));
      for (final q in questions) {
        expect(q.bands, hasLength(4));
        expect(q.options.where((o) => o.correct), hasLength(1));
        expect(q.options.length, greaterThanOrEqualTo(3));
        expect(q.options.map((o) => o.text).toSet().length, q.options.length);
      }
    });

    test('el asistente arranca en la raíz', () {
      final root = learning.node(learning.assistantRoot);
      expect(root.options, isNotEmpty);
      expect(() => learning.node('inexistente'), throwsArgumentError);
    });

    test('casos por identificador', () {
      expect(learning.caseById('night_light'), isNotNull);
      expect(learning.caseById('nada'), isNull);
    });
  });

  group('Evaluador de respuestas', () {
    const evaluator = AnswerEvaluator();
    final numeric = learning
        .questionsForModule(ModuleId.semiconductors)
        .firstWhere((q) => q.id == 's_led_num');
    final bjt = learning
        .questionsForModule(ModuleId.semiconductors)
        .firstWhere((q) => q.id == 's_bjt_num');

    test('acepta el valor dentro de la tolerancia', () {
      expect(evaluator.evaluateNumeric(numeric, '200').correct, isTrue);
      expect(evaluator.evaluateNumeric(numeric, '203').correct, isTrue);
      expect(evaluator.evaluateNumeric(numeric, '0,2k').correct, isTrue);
      expect(evaluator.evaluateNumeric(numeric, '210').correct, isFalse);
    });

    test('detecta un error de unidades', () {
      final r = evaluator.evaluateNumeric(bjt, '0.00043');
      expect(r.correct, isFalse);
      expect(r.feedback, contains('unidad'));
      expect(r.expected, '0.430 mA');
    });

    test('responde ante texto no numérico', () {
      final r = evaluator.evaluateNumeric(numeric, 'doscientos');
      expect(r.correct, isFalse);
      expect(r.feedback, contains('número'));
    });

    test('evalúa opciones y valida el índice', () {
      final q = learning.questionsForModule(ModuleId.passive).first;
      final correctIndex = q.options.indexWhere((o) => o.correct);
      expect(evaluator.evaluateOption(q, correctIndex).correct, isTrue);
      expect(evaluator.evaluateOption(q, correctIndex).selectedIndex,
          correctIndex);
      expect(() => evaluator.evaluateOption(q, 99), throwsRangeError);
    });

    test('una pregunta de opción múltiple no es numérica', () {
      final q = learning.questionsForModule(ModuleId.passive).first;
      expect(q.type, QuestionType.multipleChoice);
      expect(() => evaluator.evaluateNumeric(q, '1'), throwsArgumentError);
    });

    test('tolerancia con valor esperado cero', () {
      expect(
        AnswerEvaluator.isWithinTolerance(
            given: 0, expected: 0, tolerancePercent: 2),
        isTrue,
      );
    });
  });

  group('Repositorio de progreso', () {
    test('guarda y recupera en SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalProgressRepository(prefs);
      expect(repo.load().viewedComponents, isEmpty);

      await repo.save(const LearningProgress(
        viewedComponents: {'led'},
        bestScores: {'quiz_sensors': 50},
      ));
      final loaded = LocalProgressRepository(prefs).load();
      expect(loaded.viewedComponents, {'led'});
      expect(loaded.bestScores['quiz_sensors'], 50);

      await repo.clear();
      expect(repo.load().viewedComponents, isEmpty);
    });

    test('un dato corrupto no impide abrir la app', () async {
      SharedPreferences.setMockInitialValues({
        LocalProgressRepository.storageKey: '{no es json',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(LocalProgressRepository(prefs).load().totalAttempts, 0);
    });
  });
}
