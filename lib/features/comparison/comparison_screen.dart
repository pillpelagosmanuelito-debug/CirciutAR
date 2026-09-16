import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/simulation/simulation.dart';
import '../../providers/providers.dart';
import 'comparison_view_model.dart';

/// Comparador lado a lado de dos componentes.
class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({
    super.key,
    this.initialLeftId = 'bjt_npn',
    this.initialRightId,
  });

  final String initialLeftId;
  final String? initialRightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = comparisonViewModelProvider(
      (left: initialLeftId, right: initialRightId),
    );
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    final repo = ref.watch(componentRepositoryProvider);
    final all = repo.all();
    final left = repo.findById(state.leftId)!;
    final right = repo.findById(state.rightId)!;
    final view = state.view;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador'),
        actions: [
          IconButton(
            tooltip: 'Intercambiar',
            icon: const Icon(Icons.swap_horiz),
            onPressed: vm.swap,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _Picker(
                  value: left,
                  items: all,
                  onChanged: vm.setLeft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Picker(
                  value: right,
                  items: all,
                  onChanged: vm.setRight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (view == null)
            const EmptyState(
              icon: Icons.compare_arrows,
              message: 'Elige dos componentes distintos para compararlos.',
            )
          else ...[
            if (view.keyDifference != null)
              MessageTile(SimMessage(
                MessageLevel.info,
                'Diferencia clave: ${view.keyDifference}',
              )),
            if (view.chooseLeftWhen != null)
              SectionCard(
                title: 'Criterio de selección',
                icon: Icons.rule,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _choice(theme, left.shortName, view.chooseLeftWhen!),
                    const SizedBox(height: 8),
                    _choice(theme, right.shortName, view.chooseRightWhen!),
                  ],
                ),
              ),
            if (!view.isCurated)
              const MessageTile(SimMessage(
                MessageLevel.info,
                'Estos componentes cumplen funciones distintas: compara sus '
                'rasgos para entender por qué no son intercambiables.',
              )),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _header(theme, left, right),
                    const Divider(),
                    for (final row in view.rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.aspect,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(row.a)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(row.b)),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _choice(ThemeData theme, String name, String text) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: 'Elige $name: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }

  Widget _header(
    ThemeData theme,
    ElectronicComponent left,
    ElectronicComponent right,
  ) {
    Widget cell(ElectronicComponent c) {
      final color = AppTheme.categoryColor(c.category);
      return Expanded(
        child: Column(
          children: [
            ComponentSymbol(c.symbol, width: 90, height: 60, color: color),
            const SizedBox(height: 4),
            Text(
              c.shortName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      );
    }

    return Row(children: [cell(left), cell(right)]);
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final ElectronicComponent value;
  final List<ElectronicComponent> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.id,
          items: [
            for (final c in items)
              DropdownMenuItem<String>(
                value: c.id,
                child: Text(c.shortName, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}
