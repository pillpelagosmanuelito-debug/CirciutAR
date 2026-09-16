import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/simulation/simulation.dart';
import '../../providers/providers.dart';
import '../comparison/comparison_screen.dart';
import '../simulation/simulation_screen.dart';

/// Ficha interactiva de un componente en cuatro pestañas.
class ComponentDetailScreen extends ConsumerStatefulWidget {
  const ComponentDetailScreen({
    super.key,
    required this.componentId,
    this.initialTab = 0,
  });

  final String componentId;
  final int initialTab;

  @override
  ConsumerState<ComponentDetailScreen> createState() =>
      _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends ConsumerState<ComponentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressProvider.notifier)
          .markComponentViewed(widget.componentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(componentRepositoryProvider);
    final c = repo.findById(widget.componentId);
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.error_outline,
          message: 'No se encontró el componente.',
        ),
      );
    }
    final color = AppTheme.categoryColor(c.category);
    final simId = c.simulationId;

    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTab.clamp(0, 3).toInt(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Funcionamiento'),
              Tab(text: 'Características'),
              Tab(text: 'Aplicaciones'),
              Tab(text: 'Errores comunes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HowItWorksTab(component: c, color: color),
            _CharacteristicsTab(component: c),
            _ApplicationsTab(component: c),
            _MistakesTab(component: c),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Comparar'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ComparisonScreen(initialLeftId: c.id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Simular'),
                    onPressed: simId == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    SimulationScreen(simulationId: simId),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksTab extends StatelessWidget {
  const _HowItWorksTab({required this.component, required this.color});

  final ElectronicComponent component;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = component;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ComponentSymbol(c.symbol, width: 200, height: 130, color: color),
                const SizedBox(height: 8),
                Text(
                  c.symbol.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    TagChip(c.category.label, color: color),
                    if (c.example != null)
                      TagChip(c.example!, color: theme.colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c.summary,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        SectionCard(
          title: 'Cómo funciona',
          icon: Icons.settings_suggest_outlined,
          child: Text(c.howItWorks, style: theme.textTheme.bodyLarge),
        ),
        SectionCard(
          title: 'Relación clave',
          icon: Icons.functions,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              c.keyFormula,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SectionCard(
          title: 'Cómo identificarlo',
          icon: Icons.visibility_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BulletList(c.identificationTips),
              const SizedBox(height: 8),
              Text('Encapsulados frecuentes', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in c.packages)
                    Chip(label: Text(p), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CharacteristicsTab extends StatelessWidget {
  const _CharacteristicsTab({required this.component});

  final ElectronicComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Parámetros que debes revisar en la hoja de datos antes de elegirlo.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final ch in component.characteristics)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ch.name, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    ch.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (ch.note != null) ...[
                    const SizedBox(height: 6),
                    Text(ch.note!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ApplicationsTab extends ConsumerWidget {
  const _ApplicationsTab({required this.component});

  final ElectronicComponent component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(componentRepositoryProvider);
    final curated = repo.curatedFor(component.id);
    final success = AppTheme.messageColor(MessageLevel.success);
    final danger = AppTheme.messageColor(MessageLevel.danger);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Aplicaciones',
          icon: Icons.apps,
          child: BulletList(component.applications),
        ),
        SectionCard(
          title: 'Úsalo cuando…',
          icon: Icons.thumb_up_alt_outlined,
          child: BulletList(
            component.useWhen,
            icon: Icons.check,
            color: success,
          ),
        ),
        SectionCard(
          title: 'Evítalo cuando…',
          icon: Icons.thumb_down_alt_outlined,
          child: BulletList(
            component.avoidWhen,
            icon: Icons.close,
            color: danger,
          ),
        ),
        if (curated.isNotEmpty)
          SectionCard(
            title: 'Suele confundirse con',
            icon: Icons.compare_arrows,
            child: Column(
              children: [
                for (final cmp in curated)
                  Builder(builder: (context) {
                    final otherId =
                        cmp.aId == component.id ? cmp.bId : cmp.aId;
                    final other = repo.findById(otherId);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(other?.name ?? otherId),
                      subtitle: Text(cmp.keyDifference),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ComparisonScreen(
                            initialLeftId: component.id,
                            initialRightId: otherId,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
      ],
    );
  }
}

class _MistakesTab extends StatelessWidget {
  const _MistakesTab({required this.component});

  final ElectronicComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = AppTheme.messageColor(MessageLevel.danger);
    final warning = AppTheme.messageColor(MessageLevel.warning);
    final success = AppTheme.messageColor(MessageLevel.success);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < component.mistakes.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error ${i + 1}', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  _row(Icons.error_outline, danger, component.mistakes[i].mistake,
                      theme.textTheme.titleSmall),
                  _row(Icons.bolt, warning,
                      'Consecuencia: ${component.mistakes[i].consequence}',
                      theme.textTheme.bodyMedium),
                  _row(Icons.build_circle_outlined, success,
                      'Corrección: ${component.mistakes[i].correction}',
                      theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(IconData icon, Color color, String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
