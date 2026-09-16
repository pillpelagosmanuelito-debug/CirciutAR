import 'dart:io';

import 'package:circuitar/data/content/assistant_tree.dart';
import 'package:circuitar/data/content/cases.dart';
import 'package:circuitar/data/content/comparisons.dart';
import 'package:circuitar/data/content/modules.dart';
import 'package:circuitar/data/content/questions.dart';
import 'package:circuitar/data/repositories/component_repository.dart';
import 'package:circuitar/domain/models/electronic_component.dart';
import 'package:circuitar/domain/models/learning_module.dart';
import 'package:circuitar/domain/models/question.dart';
import 'package:circuitar/domain/services/answer_evaluator.dart';
import 'package:circuitar/domain/simulation/simulation_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las pruebas de contenido protegen la calidad pedagógica: si alguien
/// agrega una ficha incompleta o una pregunta sin retroalimentación, la
/// integración continua falla.
void main() {
  const repo = LocalComponentRepository();
  const registry = SimulationRegistry();
  const evaluator = AnswerEvaluator();
  final components = repo.all();
  final componentIds = components.map((c) => c.id).toSet();

  final allQuestions = <Question>[
    ...questionBank,
    for (final c in practicalCases) ...c.steps,
  ];

  group('Catálogo', () {
    test('hay componentes en los cuatro módulos de catálogo', () {
      for (final category in ComponentCategory.values) {
        expect(repo.byCategory(category), isNotEmpty, reason: category.label);
      }
      expect(components.length, greaterThanOrEqualTo(17));
    });

    test('los identificadores y los símbolos son únicos', () {
      expect(componentIds.length, components.length);
      final symbols = components.map((c) => c.symbol).toSet();
      expect(symbols.length, components.length);
      expect(symbols.length, SymbolType.values.length);
    });

    test('cada ficha tiene las cuatro secciones completas', () {
      for (final c in components) {
        expect(c.howItWorks.length, greaterThan(120), reason: c.id);
        expect(c.characteristics.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.applications.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.mistakes.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.useWhen, isNotEmpty, reason: c.id);
        expect(c.avoidWhen, isNotEmpty, reason: c.id);
        expect(c.identificationTips, isNotEmpty, reason: c.id);
        expect(c.packages, isNotEmpty, reason: c.id);
        for (final m in c.mistakes) {
          expect(m.consequence, isNotEmpty, reason: c.id);
          expect(m.correction, isNotEmpty, reason: c.id);
        }
      }
    });

    test('cada ficha declara todos los rasgos comparables', () {
      for (final c in components) {
        for (final key in TraitKeys.all) {
          expect(c.traits[key], isNotNull, reason: '${c.id}: $key');
        }
      }
    });

    test('cada componente tiene una simulación registrada', () {
      for (final c in components) {
        expect(c.simulationId, isNotNull, reason: c.id);
        expect(registry.find(c.simulationId!), isNotNull, reason: c.id);
      }
      final used = components.map((c) => c.simulationId).toSet();
      for (final s in SimulationRegistry.all) {
        expect(used, contains(s.id), reason: 'Simulación huérfana: ${s.id}');
      }
    });

    test('hay seis módulos numerados del 1 al 6', () {
      expect(learningModules.map((m) => m.number).toList(), [1, 2, 3, 4, 5, 6]);
      expect(learningModules.map((m) => m.id).toSet().length, 6);
    });
  });

  group('Preguntas', () {
    test('los identificadores son únicos', () {
      final ids = allQuestions.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('las de opción múltiple tienen una sola respuesta correcta', () {
      for (final q in allQuestions.where(
        (q) => q.type == QuestionType.multipleChoice,
      )) {
        expect(q.options.length, greaterThanOrEqualTo(3), reason: q.id);
        expect(q.options.where((o) => o.correct).length, 1, reason: q.id);
        for (final o in q.options) {
          expect(o.feedback.trim(), isNotEmpty, reason: q.id);
        }
        expect(q.options.map((o) => o.text).toSet().length, q.options.length,
            reason: q.id);
      }
    });

    test('las numéricas se calculan con una simulación existente', () {
      for (final q in allQuestions.where(
        (q) => q.type == QuestionType.numeric,
      )) {
        final spec = q.numeric!;
        final sim = registry.find(spec.simulationId);
        expect(sim, isNotNull, reason: q.id);
        for (final key in spec.inputs.keys) {
          expect(sim!.parameters.map((p) => p.key), contains(key),
              reason: '${q.id}: $key');
        }
        final value = evaluator.expectedValue(spec);
        expect(value.isFinite, isTrue, reason: q.id);
        expect(value, isNot(0), reason: q.id);
      }
    });

    test('las respuestas numéricas coinciden con el enunciado', () {
      final expected = <String, double>{
        'p_power_num': 306.38,
        'p_loading_num': 0.714,
        'p_ripple_num': 1.894,
        'p_tau_num': 1.0,
        'a_opamp_num': 5.5,
        'a_reg_num': 3.5,
        'a_555_num': 0.988,
        's_led_num': 200,
        's_bjt_num': 0.43,
        's_zener_num': 26.26,
        'n_lm35_num': 370,
        'n_echo_num': 2.912,
        'n_ntc_num': 2.5,
        'fc_vth': 0.845,
        'th_amp': 4.07,
        'th_tone': 6.87,
      };
      for (final entry in expected.entries) {
        final q = allQuestions.firstWhere((q) => q.id == entry.key);
        expect(
          evaluator.expectedValue(q.numeric!),
          closeTo(entry.value, entry.value.abs() * 0.005),
          reason: entry.key,
        );
      }
    });

    test('los componentes referidos existen', () {
      for (final q in allQuestions) {
        if (q.componentId != null) {
          expect(componentIds, contains(q.componentId), reason: q.id);
        }
      }
    });

    test('cada módulo evaluable tiene al menos cinco preguntas', () {
      for (final module in [
        ModuleId.passive,
        ModuleId.active,
        ModuleId.semiconductors,
        ModuleId.sensors,
        ModuleId.assessments,
      ]) {
        final count = questionBank.where((q) => q.module == module).length;
        expect(count, greaterThanOrEqualTo(5), reason: module.name);
      }
    });
  });

  group('Casos, comparaciones y asistente', () {
    test('los casos refieren componentes existentes', () {
      final ids = practicalCases.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final c in practicalCases) {
        expect(c.steps.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.takeaways, isNotEmpty, reason: c.id);
        for (final id in c.componentIds) {
          expect(componentIds, contains(id), reason: c.id);
        }
      }
    });

    test('las comparaciones curadas son válidas y no se repiten', () {
      final seen = <String>{};
      for (final c in curatedComparisons) {
        expect(componentIds, contains(c.aId));
        expect(componentIds, contains(c.bId));
        expect(c.aId, isNot(c.bId));
        final key = ([c.aId, c.bId]..sort()).join('|');
        expect(seen.add(key), isTrue, reason: key);
      }
    });

    test('el árbol del asistente es consistente y sin ciclos', () {
      final nodes = {for (final n in assistantTree) n.id: n};
      expect(nodes.length, assistantTree.length);
      expect(nodes, contains(assistantRootId));

      final reached = <String>{};
      final recommended = <String>{};
      void visit(String id, Set<String> path) {
        expect(path.contains(id), isFalse, reason: 'Ciclo en $id');
        final node = nodes[id];
        expect(node, isNotNull, reason: 'Nodo inexistente: $id');
        reached.add(id);
        for (final o in node!.options) {
          final rec = o.recommendation;
          if (rec != null) {
            expect(componentIds, contains(rec.componentId));
            if (rec.alternativeId != null) {
              expect(componentIds, contains(rec.alternativeId));
            }
            expect(rec.checks, isNotEmpty);
            recommended.add(rec.componentId);
          } else {
            visit(o.nextId!, {...path, id});
          }
        }
      }

      visit(assistantRootId, {});
      expect(reached, nodes.keys.toSet(), reason: 'Hay nodos inalcanzables');
      expect(recommended, componentIds,
          reason: 'Todo componente debe poder recomendarse');
    });
  });

  group('Ortografía', () {
    // Palabras que en la interfaz siempre deben llevar tilde. Se revisan
    // solo dentro de cadenas de texto.
    const accented = <String, String>{
      'electronica': 'electrónica',
      'electronico': 'electrónico',
      'funcion': 'función',
      'tension': 'tensión',
      'simulacion': 'simulación',
      'evaluacion': 'evaluación',
      'aplicacion': 'aplicación',
      'practica': 'práctica',
      'caracteristica': 'característica',
      'polarizacion': 'polarización',
      'saturacion': 'saturación',
      'region': 'región',
      'conduccion': 'conducción',
      'tambien': 'también',
      'termica': 'térmica',
      'energia': 'energía',
      'codigo': 'código',
      'modulo': 'módulo',
      'simbolo': 'símbolo',
      'numero': 'número',
      'calculo': 'cálculo',
      'minimo': 'mínimo',
      'maximo': 'máximo',
      'tipico': 'típico',
      'logico': 'lógico',
      'analogico': 'analógico',
      'identificacion': 'identificación',
      'seleccion': 'selección',
      'comparacion': 'comparación',
      'regulacion': 'regulación',
      'rapido': 'rápido',
      'dispositivo movil': 'dispositivo móvil',
      'dinamica': 'dinámica',
      'potenciometro': 'potenciómetro',
      'electrolitico': 'electrolítico',
      'ceramico': 'cerámico',
      'ultrasonico': 'ultrasónico',
      'operacion': 'operación',
      'relacion': 'relación',
      'resolucion': 'resolución',
      'precision': 'precisión',
      'proteccion': 'protección',
      'configuracion': 'configuración',
      'alimentacion': 'alimentación',
      'medicion': 'medición',
      'decision': 'decisión',
      'situacion': 'situación',
    };

    test('los textos de la interfaz llevan las tildes correctas', () {
      final stringLiteral = RegExp(r"'((?:\\.|[^'\\])*)'");
      final problems = <String>[];
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('import ')) continue;
          for (final m in stringLiteral.allMatches(line)) {
            final text = m.group(1)!.toLowerCase();
            for (final entry in accented.entries) {
              final pattern = RegExp('(?<![a-záéíóúñü_])${entry.key}s?(?![a-záéíóúñü_])');
              if (pattern.hasMatch(text)) {
                problems.add('${file.path}:${i + 1}: «${entry.key}» → '
                    '«${entry.value}»');
              }
            }
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  });
}
