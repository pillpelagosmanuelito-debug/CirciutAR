import 'package:circuitar/data/repositories/learning_repository.dart';
import 'package:circuitar/data/repositories/progress_repository.dart';
import 'package:circuitar/domain/models/competency.dart';
import 'package:circuitar/domain/simulation/color_code.dart';
import 'package:circuitar/features/assessment/quiz_view_model.dart';
import 'package:circuitar/features/assistant/assistant_view_model.dart';
import 'package:circuitar/features/cases/case_view_model.dart';
import 'package:circuitar/features/catalog/catalog_view_model.dart';
import 'package:circuitar/features/comparison/comparison_view_model.dart';
import 'package:circuitar/features/identification/color_code_view_model.dart';
import 'package:circuitar/features/simulation/simulation_view_model.dart';
import 'package:circuitar/domain/models/learning_module.dart';
import 'package:circuitar/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryProgressRepository progressRepo;
  late ProviderContainer container;

  setUp(() {
    progressRepo = InMemoryProgressRepository();
    container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progressRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('Progreso', () {
    test('registra fichas, simulaciones y respuestas', () async {
      final vm = container.read(progressProvider.notifier);
      await vm.markComponentViewed('led');
      await vm.markComponentViewed('led');
      await vm.markSimulationUsed('ohm_power');
      await vm.recordAnswer(
        competency: Competency.selection,
        correct: false,
        componentId: 'led',
      );
      await vm.recordAnswer(
        competency: Competency.selection,
        correct: true,
        componentId: 'resistor',
      );
      final p = container.read(progressProvider);
      expect(p.viewedComponents, {'led'});
      expect(p.usedSimulations, {'ohm_power'});
      expect(p.statFor(Competency.selection).attempts, 2);
      expect(p.statFor(Competency.selection).correct, 1);
      expect(p.reviewSuggestions(), ['led']);
      expect(progressRepo.load().viewedComponents, {'led'});
    });

    test('un acierto reduce el error pendiente del componente', () async {
      final vm = container.read(progressProvider.notifier);
      await vm.recordAnswer(
          competency: Competency.functional, correct: false, componentId: 'ntc');
      await vm.recordAnswer(
          competency: Competency.functional, correct: true, componentId: 'ntc');
      expect(container.read(progressProvider).reviewSuggestions(), isEmpty);
    });

    test('guarda solo el mejor puntaje y permite reiniciar', () async {
      final vm = container.read(progressProvider.notifier);
      await vm.recordQuizScore('quiz_passive', 60);
      await vm.recordQuizScore('quiz_passive', 40);
      expect(container.read(progressProvider).bestScores['quiz_passive'], 60);
      await vm.reset();
      expect(container.read(progressProvider).bestScores, isEmpty);
    });
  });

  group('Simulación', () {
    test('recalcula al cambiar un parámetro y respeta los límites', () {
      final provider = simulationViewModelProvider('ohm_power');
      final sub = container.listen(provider, (_, __) {});
      final vm = container.read(provider.notifier);
      expect(container.read(provider).result.value('i'),
          closeTo(12 / 470, 1e-9));

      vm.setValue('r', 1000);
      expect(container.read(provider).result.value('i'),
          closeTo(0.012, 1e-12));
      expect(container.read(provider).touched, isTrue);
      expect(container.read(progressProvider).usedSimulations,
          contains('ohm_power'));

      vm.setValue('v', 999);
      expect(container.read(provider).valueOf('v'), 24);

      vm.setFromSlider('v', 0);
      expect(container.read(provider).valueOf('v'), 0);

      vm.reset();
      expect(container.read(provider).valueOf('r'), 470);
      expect(container.read(provider).touched, isFalse);
      sub.close();
    });
  });

  group('Evaluación', () {
    test('flujo completo con registro por competencia', () {
      final provider = quizViewModelProvider(QuizIds.passive);
      final sub = container.listen(provider, (_, __) {});
      final vm = container.read(provider.notifier);
      final total = container.read(provider).total;

      vm.next();
      expect(container.read(provider).index, 0,
          reason: 'No avanza sin responder');

      for (var i = 0; i < total; i++) {
        final q = container.read(provider).current;
        if (q.options.isNotEmpty) {
          vm.selectOption(q.options.indexWhere((o) => o.correct));
          vm.selectOption(0);
        } else {
          vm.submitNumeric('   ');
          expect(container.read(provider).currentResult, isNull);
          vm.submitNumeric('-1');
        }
        vm.next();
      }

      final s = container.read(provider);
      expect(s.finished, isTrue);
      final mc = s.quiz.questions.where((q) => q.options.isNotEmpty).length;
      expect(s.correctCount, mc);
      expect(s.missed.length, total - mc);
      final sum = s.byCompetency.values.fold<int>(0, (a, b) => a + b.$2);
      expect(sum, total);

      final p = container.read(progressProvider);
      expect(p.bestScores[QuizIds.passive], s.percent);
      expect(p.totalAttempts, total);
      sub.close();
    });

    test('las prácticas no guardan puntaje', () {
      final provider = quizViewModelProvider(QuizIds.symbolPractice);
      final sub = container.listen(provider, (_, __) {});
      final vm = container.read(provider.notifier);
      final total = container.read(provider).total;
      for (var i = 0; i < total; i++) {
        vm.selectOption(0);
        vm.next();
      }
      expect(container.read(provider).finished, isTrue);
      expect(container.read(progressProvider).bestScores, isEmpty);
      sub.close();
    });
  });

  group('Caso práctico', () {
    test('introducción, decisiones y cierre', () {
      final provider = caseViewModelProvider('power_supply');
      final sub = container.listen(provider, (_, __) {});
      final vm = container.read(provider.notifier);
      expect(container.read(provider).stage, CaseStage.intro);

      vm.selectOption(0);
      expect(container.read(provider).results, isEmpty,
          reason: 'No se responde antes de comenzar');

      vm.start();
      final steps = container.read(provider).totalSteps;
      for (var i = 0; i < steps; i++) {
        final q = container.read(provider).currentStep;
        if (q.options.isNotEmpty) {
          vm.selectOption(q.options.indexWhere((o) => o.correct));
        } else {
          final expected = container
              .read(answerEvaluatorProvider)
              .expectedValue(q.numeric!);
          vm.submitNumeric(expected.toStringAsFixed(4));
        }
        expect(container.read(provider).currentResult?.correct, isTrue,
            reason: q.id);
        vm.next();
      }
      final s = container.read(provider);
      expect(s.stage, CaseStage.summary);
      expect(s.correctCount, steps);
      expect(container.read(progressProvider).completedCases,
          contains('power_supply'));
      sub.close();
    });
  });

  group('Asistente', () {
    test('recorre, recomienda y retrocede', () {
      final sub = container.listen(assistantViewModelProvider, (_, __) {});
      final vm = container.read(assistantViewModelProvider.notifier);
      final root = container.read(assistantViewModelProvider).current;
      final switching = root.options
          .indexWhere((o) => o.label.startsWith('Encender o apagar'));
      vm.choose(switching);
      expect(container.read(assistantViewModelProvider).current.id,
          'switching');

      final high = container
          .read(assistantViewModelProvider)
          .current
          .options
          .indexWhere((o) => o.label == 'Más de 200 mA');
      vm.choose(high);
      vm.choose(0);
      final s = container.read(assistantViewModelProvider);
      expect(s.finished, isTrue);
      expect(s.recommendation!.componentId, 'mosfet_n');
      expect(s.history, hasLength(3));

      vm.choose(0);
      expect(container.read(assistantViewModelProvider).history, hasLength(3),
          reason: 'Terminado, no acepta más respuestas');

      vm.back();
      final back = container.read(assistantViewModelProvider);
      expect(back.finished, isFalse);
      expect(back.current.id, 'switching_high');
      expect(back.history, hasLength(2));
      sub.close();
    });
  });

  group('Comparador', () {
    test('elige pareja por defecto, intercambia y detecta iguales', () {
      final provider =
          comparisonViewModelProvider((left: 'ntc', right: null));
      final sub = container.listen(provider, (_, __) {});
      final vm = container.read(provider.notifier);
      expect(container.read(provider).rightId, 'lm35');
      expect(container.read(provider).view!.isCurated, isTrue);

      vm.swap();
      expect(container.read(provider).leftId, 'lm35');

      vm.setRight('lm35');
      expect(container.read(provider).sameComponent, isTrue);
      expect(container.read(provider).view, isNull);
      sub.close();
    });
  });

  group('Código de colores', () {
    test('cambia bandas válidas e ignora las inválidas', () {
      final sub = container.listen(colorCodeViewModelProvider, (_, __) {});
      final vm = container.read(colorCodeViewModelProvider.notifier);
      expect(container.read(colorCodeViewModelProvider).reading.ohms, 4700);

      vm.setBand(2, BandColor.orange);
      expect(container.read(colorCodeViewModelProvider).reading.ohms, 47000);

      vm.setBand(0, BandColor.gold);
      expect(container.read(colorCodeViewModelProvider).bands.first,
          BandColor.yellow);

      vm.setBandCount(5);
      final s = container.read(colorCodeViewModelProvider);
      expect(s.bandCount, 5);
      expect(s.reading.ohms, 10000);
      expect(s.roleOf(3), BandRole.multiplier);
      sub.close();
    });
  });

  group('Catálogo', () {
    test('filtra por texto y categoría', () {
      final vm = container.read(catalogViewModelProvider.notifier);
      final all = container.read(catalogViewModelProvider).results.length;
      vm.setCategory(ComponentCategory.passive);
      expect(container.read(catalogViewModelProvider).results.length,
          lessThan(all));
      vm.setQuery('electrolitico');
      expect(container.read(catalogViewModelProvider).results.single.id,
          'capacitor_electrolytic');
      vm.clear();
      expect(container.read(catalogViewModelProvider).results.length, all);
    });
  });
}
