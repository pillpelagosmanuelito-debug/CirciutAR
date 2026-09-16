import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'simulation_screen.dart';

/// Lista de todas las simulaciones del laboratorio.
class LabListScreen extends ConsumerWidget {
  const LabListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(componentRepositoryProvider).all();
    final used = ref.watch(progressProvider).usedSimulations;
    final registry = ref.watch(simulationRegistryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorio de simulaciones')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: components.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = components[i];
          final simId = c.simulationId;
          final sim = simId == null ? null : registry.find(simId);
          if (sim == null) return const SizedBox.shrink();
          final color = AppTheme.categoryColor(c.category);
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withAlpha(35),
                child: Icon(Icons.science_outlined, color: color),
              ),
              title: Text(sim.title),
              subtitle: Text(c.category.label),
              trailing: used.contains(sim.id)
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SimulationScreen(simulationId: sim.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
