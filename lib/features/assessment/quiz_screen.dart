import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/common_widgets.dart';
import '../../domain/models/competency.dart';
import '../../providers/providers.dart';
import '../catalog/component_detail_screen.dart';
import 'question_view.dart';
import 'quiz_view_model.dart';

/// Pantalla de evaluación: una pregunta por vez con retroalimentación.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quizViewModelProvider(quizId);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);

    if (state.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(state.quiz.title)),
        body: const EmptyState(
          icon: Icons.quiz_outlined,
          message: 'Esta evaluación todavía no tiene preguntas.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(state.quiz.title)),
      body: state.finished
          ? _QuizSummary(state: state, onRestart: vm.restart)
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (state.index + (state.currentResult != null ? 1 : 0)) /
                      state.total,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Pregunta ${state.index + 1} de ${state.total}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      QuestionView(
                        question: state.current,
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
                        onPressed:
                            state.currentResult == null ? null : vm.next,
                        child: Text(
                          state.isLast ? 'Ver resultados' : 'Siguiente',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuizSummary extends ConsumerWidget {
  const _QuizSummary({required this.state, required this.onRestart});

  final QuizState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(componentRepositoryProvider);
    final percent = state.percent;
    final level = MasteryLevel.fromStats(
      attempts: state.total,
      correct: state.correctCount,
    );
    final missedComponents = <String>{
      for (final q in state.missed)
        if (q.componentId != null) q.componentId!,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('$percent %', style: theme.textTheme.displayMedium),
                Text(
                  '${state.correctCount} de ${state.total} respuestas correctas',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Nivel: ${level.label}', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Resultado por competencia',
          icon: Icons.insights,
          child: Column(
            children: [
              for (final entry in state.byCompetency.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(entry.key.label)),
                          Text('${entry.value.$1}/${entry.value.$2}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: entry.value.$2 == 0
                            ? 0.0
                            : entry.value.$1 / entry.value.$2,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (missedComponents.isNotEmpty)
          SectionCard(
            title: 'Repaso recomendado',
            icon: Icons.menu_book_outlined,
            child: Column(
              children: [
                for (final id in missedComponents)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.report_gmailerrorred),
                    title: Text(repo.findById(id)?.name ?? id),
                    subtitle: const Text('Revisa sus errores comunes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ComponentDetailScreen(
                          componentId: id,
                          initialTab: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay),
          label: const Text('Intentar de nuevo'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
      ],
    );
  }
}
