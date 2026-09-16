import 'package:circuitar/app.dart';
import 'package:circuitar/core/widgets/symbol_painter.dart';
import 'package:circuitar/data/repositories/learning_repository.dart';
import 'package:circuitar/data/repositories/progress_repository.dart';
import 'package:circuitar/domain/models/electronic_component.dart';
import 'package:circuitar/features/assessment/quiz_screen.dart';
import 'package:circuitar/features/catalog/component_detail_screen.dart';
import 'package:circuitar/features/identification/identification_screens.dart';
import 'package:circuitar/features/simulation/simulation_screen.dart';
import 'package:circuitar/domain/simulation/simulation_registry.dart';
import 'package:circuitar/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {InMemoryProgressRepository? repo}) {
  return ProviderScope(
    overrides: [
      progressRepositoryProvider
          .overrideWithValue(repo ?? InMemoryProgressRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

void _usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('la app abre en Inicio y navega por las pestañas',
      (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider
              .overrideWithValue(InMemoryProgressRepository()),
        ],
        child: const CircuitArApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CircuitAR'), findsOneWidget);
    expect(find.text('Componentes pasivos'), findsWidgets);

    await tester.tap(find.text('Catálogo').last);
    await tester.pumpAndSettle();
    expect(find.text('Catálogo de componentes'), findsOneWidget);
    expect(find.text('Resistor'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'zener');
    await tester.pumpAndSettle();
    expect(find.text('Diodo Zener'), findsOneWidget);
    expect(find.text('Resistor'), findsNothing);

    await tester.tap(find.text('Práctica').last);
    await tester.pumpAndSettle();
    expect(find.text('Asistente de selección'), findsOneWidget);

    await tester.tap(find.text('Progreso').last);
    await tester.pumpAndSettle();
    expect(find.text('Dominio por competencia'), findsOneWidget);
  });

  testWidgets('la ficha muestra las cuatro pestañas y registra la visita',
      (tester) async {
    _usePhone(tester);
    final repo = InMemoryProgressRepository();
    await tester.pumpWidget(
      _wrap(const ComponentDetailScreen(componentId: 'led'), repo: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Diodo LED'), findsOneWidget);
    expect(find.text('Cómo funciona'), findsOneWidget);
    expect(repo.load().viewedComponents, contains('led'));

    final mistakesTab = find.widgetWithText(Tab, 'Errores comunes');
    await tester.ensureVisible(mistakesTab);
    await tester.pumpAndSettle();
    await tester.tap(mistakesTab);
    await tester.pumpAndSettle();
    expect(find.text('Conectarlo sin resistor limitador.'), findsOneWidget);

    final applicationsTab = find.widgetWithText(Tab, 'Aplicaciones');
    await tester.ensureVisible(applicationsTab);
    await tester.pumpAndSettle();
    await tester.tap(applicationsTab);
    await tester.pumpAndSettle();
    expect(find.text('Úsalo cuando…'), findsOneWidget);
  });

  testWidgets('todas las simulaciones se dibujan sin errores', (tester) async {
    _usePhone(tester);
    for (final sim in SimulationRegistry.all) {
      await tester.pumpWidget(
        _wrap(SimulationScreen(simulationId: sim.id)),
      );
      await tester.pumpAndSettle();
      expect(find.text(sim.title), findsOneWidget, reason: sim.id);
      expect(tester.takeException(), isNull, reason: sim.id);
    }
  });

  testWidgets('mover un control actualiza los resultados', (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(
      _wrap(const SimulationScreen(simulationId: 'ohm_power')),
    );
    await tester.pumpAndSettle();
    expect(find.text('25.5 mA'), findsOneWidget);

    await tester.drag(find.byType(Slider).first, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('0 A'), findsOneWidget);
  });

  testWidgets('todos los símbolos se dibujan', (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final t in SymbolType.values) ComponentSymbol(t),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ComponentSymbol),
        findsNWidgets(SymbolType.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('una evaluación se responde con retroalimentación',
      (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(
      _wrap(const QuizScreen(quizId: QuizIds.symbols)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pregunta 1 de 6'), findsOneWidget);

    await tester.tap(find.text('Diodo Zener'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Correcto'), findsWidgets);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Pregunta 2 de 6'), findsOneWidget);
  });

  testWidgets('el lector de colores muestra el valor', (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(_wrap(const ColorCodeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('4.70 kΩ'), findsOneWidget);
  });
}
