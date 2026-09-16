import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/learning_module.dart';
import '../../providers/providers.dart';
import '../assessment/question_view.dart';
import '../catalog/component_detail_screen.dart';
import 'case_view_model.dart';

/// Módulo 5: lista de casos prácticos.
class CaseListScreen extends ConsumerWidget {
  const CaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(learningRepositoryProvider).cases();
    final completed = ref.watch(progressProvider).completedCases;
    final color = AppTheme.moduleColor(ModuleId.applications);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Aplicaciones reales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Diseña circuitos completos tomando decisiones como en un '
            'proyecto profesional. Cada respuesta explica el porqué.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final c in cases)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(35),
                  child: Icon(
                    completed.contains(c.id)
                        ? Icons.check
                        : Icons.engineering,
                    color: color,
                  ),
                ),
                title: Text(c.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_difficulty(c.difficulty)} · ${c.steps.length} decisiones',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CaseScreen(caseId: c.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _difficulty(int d) => switch (d) {
        1 => 'Básico',
        2 => 'Intermedio',
        _ => 'Avanzado',
      };
}

/// Desarrollo de un caso práctico.
class CaseScreen extends ConsumerWidget {
  const CaseScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = caseViewModelProvider(caseId);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    final c = state.practicalCase;

    final Widget body = switch (state.stage) {
      CaseStage.intro => _CaseIntro(state: state, onStart: vm.start),
      CaseStage.steps => _CaseStep(state: state, vm: vm),
      CaseStage.summary => _CaseSummary(state: state, onRestart: vm.restart),
    };

    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: body,
    );
  }
}

class _CaseIntro extends ConsumerWidget {
  const _CaseIntro({required this.state, required this.onStart});

  final CaseState state;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = state.practicalCase;
    final repo = ref.watch(componentRepositoryProvider);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Situación',
          icon: Icons.business_center_outlined,
          child: Text(c.context, style: theme.textTheme.bodyLarge),
        ),
        SectionCard(
          title: 'Tu objetivo',
          icon: Icons.flag_outlined,
          child: Text(c.goal),
        ),
        SectionCard(
          title: 'Componentes involucrados',
          icon: Icons.memory,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final id in c.componentIds)
                if (repo.findById(id) case final comp?)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ComponentDetailScreen(componentId: id),
                      ),
                    ),
                    child: SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          ComponentSymbol(comp.symbol, width: 72, height: 48),
                          Text(
                            comp.shortName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow),
          label: Text('Comenzar (${c.steps.length} decisiones)'),
        ),
      ],
    );
  }
}

class _CaseStep extends StatelessWidget {
  const _CaseStep({required this.state, required this.vm});

  final CaseState state;
  final CaseViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (state.step + (state.currentResult != null ? 1 : 0)) /
              state.totalSteps,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Decisión ${state.step + 1} de ${state.totalSteps}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              QuestionView(
                question: state.currentStep,
                result: state.currentResult,
                onSelectOption: vm.selectOption,
                onSubmitNumeric: vm.submitNumeric,
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.currentResult == null ? null : vm.next,
                child: Text(
                  state.isLastStep ? 'Cerrar el caso' : 'Siguiente decisión',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CaseSummary extends StatelessWidget {
  const _CaseSummary({required this.state, required this.onRestart});

  final CaseState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = state.practicalCase;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.verified, size: 48, color: Colors.green),
                const SizedBox(height: 8),
                Text('Caso completado', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  '${state.correctCount} de ${state.totalSteps} decisiones '
                  'correctas al primer intento',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Lo que debes llevarte',
          icon: Icons.school_outlined,
          child: BulletList(c.takeaways, icon: Icons.check),
        ),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay),
          label: const Text('Repetir el caso'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver a los casos'),
        ),
      ],
    );
  }
}
