import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/common_widgets.dart';
import '../../domain/models/competency.dart';
import '../../domain/models/progress.dart';
import '../../providers/providers.dart';
import '../catalog/component_detail_screen.dart';

/// Resumen del progreso por competencia y recomendaciones de repaso.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final repo = ref.watch(componentRepositoryProvider);
    final learning = ref.watch(learningRepositoryProvider);
    final theme = Theme.of(context);
    final review = progress.reviewSuggestions();
    final quizzes = learning.quizzes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi progreso'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar progreso',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Dominio por competencia',
            icon: Icons.insights,
            child: Column(
              children: [
                for (final c in Competency.values)
                  _CompetencyRow(competency: c, stat: progress.statFor(c)),
              ],
            ),
          ),
          if (progress.totalAttempts == 0)
            const EmptyState(
              icon: Icons.school_outlined,
              message: 'Responde evaluaciones o casos para ver tu dominio '
                  'por competencia.',
            ),
          if (review.isNotEmpty)
            SectionCard(
              title: 'Repaso recomendado',
              icon: Icons.menu_book_outlined,
              child: Column(
                children: [
                  for (final id in review)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.report_gmailerrorred),
                      title: Text(repo.findById(id)?.name ?? id),
                      subtitle: Text(
                        '${progress.mistakesByComponent[id]} respuestas por '
                        'corregir · revisa sus errores comunes',
                      ),
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
          SectionCard(
            title: 'Evaluaciones',
            icon: Icons.fact_check_outlined,
            child: Column(
              children: [
                for (final q in quizzes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(q.title)),
                        Text(
                          progress.bestScores[q.id] == null
                              ? 'Pendiente'
                              : '${progress.bestScores[q.id]} %',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Exploración',
            icon: Icons.explore_outlined,
            child: Column(
              children: [
                _countRow('Fichas revisadas', progress.viewedComponents.length,
                    repo.all().length),
                _countRow('Simulaciones usadas',
                    progress.usedSimulations.length, repo.all().length),
                _countRow('Casos completados', progress.completedCases.length,
                    learning.cases().length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countRow(String label, int value, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value/$total'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total == 0 ? 0.0 : value / total,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar el progreso?'),
        content: const Text(
          'Se borrarán tus puntajes, fichas revisadas y casos completados '
          'de este dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(progressProvider.notifier).reset();
    }
  }
}

class _CompetencyRow extends StatelessWidget {
  const _CompetencyRow({required this.competency, required this.stat});

  final Competency competency;
  final CompetencyStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = stat.level;
    final color = switch (level) {
      MasteryLevel.noEvidence => theme.colorScheme.outline,
      MasteryLevel.developing => Colors.red.shade400,
      MasteryLevel.acceptable => Colors.orange.shade600,
      MasteryLevel.achieved => Colors.green.shade600,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(competency.label, style: theme.textTheme.titleSmall),
              ),
              TagChip(level.label, color: color),
            ],
          ),
          const SizedBox(height: 2),
          Text(competency.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: stat.attempts == 0 ? 0.0 : stat.rate,
            color: color,
            minHeight: 6,
          ),
          const SizedBox(height: 2),
          Text(
            stat.attempts == 0
                ? 'Sin respuestas registradas'
                : '${stat.correct} de ${stat.attempts} respuestas correctas',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
