import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/assistant.dart';
import '../../domain/simulation/simulation.dart';
import '../../providers/providers.dart';
import '../catalog/component_detail_screen.dart';
import 'assistant_view_model.dart';

/// Asistente que recomienda un componente a partir de la necesidad.
class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantViewModelProvider);
    final vm = ref.read(assistantViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de selección'),
        actions: [
          IconButton(
            tooltip: 'Volver a empezar',
            icon: const Icon(Icons.restart_alt),
            onPressed: vm.restart,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MessageTile(SimMessage(
            MessageLevel.info,
            'El asistente usa reglas técnicas revisables, no inteligencia '
            'artificial: la misma necesidad siempre recibe la misma '
            'recomendación y su justificación.',
          )),
          if (state.history.isNotEmpty) ...[
            Text('Tu recorrido', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            for (final step in state.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(step.answer)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (state.recommendation case final rec?)
            _RecommendationCard(recommendation: rec)
          else ...[
            Text(state.current.question, style: theme.textTheme.titleLarge),
            if (state.current.hint != null) ...[
              const SizedBox(height: 4),
              Text(state.current.hint!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            for (var i = 0; i < state.current.options.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(state.current.options[i].label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => vm.choose(i),
                ),
              ),
          ],
          const SizedBox(height: 12),
          if (state.canGoBack)
            OutlinedButton.icon(
              onPressed: vm.back,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Cambiar la última respuesta'),
            ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(componentRepositoryProvider);
    final c = repo.findById(recommendation.componentId);
    final theme = Theme.of(context);
    if (c == null) return const SizedBox.shrink();
    final color = AppTheme.categoryColor(c.category);
    final altId = recommendation.alternativeId;
    final alt = altId == null ? null : repo.findById(altId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Recomendación', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ComponentSymbol(c.symbol, width: 150, height: 100, color: color),
                const SizedBox(height: 8),
                Text(c.name, style: theme.textTheme.headlineSmall),
                if (c.example != null)
                  Text(c.example!, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Text(
                  recommendation.reason,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Antes de comprarlo, verifica',
          icon: Icons.checklist,
          child: BulletList(recommendation.checks, icon: Icons.check_box_outlined),
        ),
        if (alt != null && recommendation.alternativeNote != null)
          MessageTile(SimMessage(
            MessageLevel.info,
            'Alternativa — ${alt.name}: ${recommendation.alternativeNote}',
          )),
        FilledButton.icon(
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('Ver la ficha completa'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ComponentDetailScreen(componentId: c.id),
            ),
          ),
        ),
      ],
    );
  }
}
