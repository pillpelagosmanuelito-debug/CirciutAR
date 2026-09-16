import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';
import '../../providers/providers.dart';
import 'catalog_view_model.dart';
import 'component_detail_screen.dart';

/// Catálogo completo con búsqueda y filtros.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final vm = ref.read(catalogViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de componentes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: vm.setQuery,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre, código o aplicación',
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: state.category == null,
                    onSelected: (_) => vm.setCategory(null),
                  ),
                ),
                for (final c in ComponentCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_plural(c)),
                      selected: state.category == c,
                      onSelected: (_) => vm.setCategory(c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: state.results.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    message: 'No hay componentes que coincidan con la búsqueda.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.results.length,
                    itemBuilder: (context, i) =>
                        ComponentTile(component: state.results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  static String _plural(ComponentCategory c) => switch (c) {
        ComponentCategory.passive => 'Pasivos',
        ComponentCategory.active => 'Activos',
        ComponentCategory.semiconductor => 'Semiconductores',
        ComponentCategory.sensor => 'Sensores',
      };
}

/// Fila de un componente con su símbolo.
class ComponentTile extends ConsumerWidget {
  const ComponentTile({super.key, required this.component});

  final ElectronicComponent component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewed = ref.watch(
      progressProvider.select((p) => p.viewedComponents.contains(component.id)),
    );
    final color = AppTheme.categoryColor(component.category);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ComponentDetailScreen(componentId: component.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(6),
                child: ComponentSymbol(
                  component.symbol,
                  width: 66,
                  height: 44,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(component.name, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      component.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                viewed ? Icons.check_circle : Icons.chevron_right,
                color: viewed ? Colors.green : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
