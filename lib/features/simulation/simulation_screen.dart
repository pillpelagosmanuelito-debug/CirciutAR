import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/curve_chart.dart';
import '../../domain/simulation/simulation.dart';
import 'simulation_view_model.dart';

/// Laboratorio de un componente: parámetros, resultados y curva.
class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key, required this.simulationId});

  final String simulationId;

  static String formatOutput(SimOutput o) {
    if (o.plain) {
      final isInt = o.value == o.value.roundToDouble();
      return EngFormat.plain(o.value, o.unit, decimals: isInt ? 0 : 2);
    }
    return EngFormat.format(o.value, o.unit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = simulationViewModelProvider(simulationId);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    final sim = state.simulation;
    final result = state.result;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(sim.title),
        actions: [
          IconButton(
            tooltip: 'Restablecer valores',
            icon: const Icon(Icons.restart_alt),
            onPressed: vm.reset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionCard(
            title: 'Qué vas a descubrir',
            icon: Icons.lightbulb_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sim.learningGoal),
                const SizedBox(height: 8),
                Text(
                  'Circuito: ${sim.circuit}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Parámetros',
            icon: Icons.tune,
            child: Column(
              children: [
                for (final p in sim.parameters)
                  _ParameterControl(
                    parameter: p,
                    value: state.valueOf(p.key),
                    onSlider: (pos) => vm.setFromSlider(p.key, pos),
                    onOption: (i) => vm.setValue(p.key, i.toDouble()),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Resultados',
            icon: Icons.analytics_outlined,
            trailing: result.state == null
                ? null
                : TagChip(result.state!, color: theme.colorScheme.tertiary),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in result.outputs)
                  _OutputTile(label: o.label, value: formatOutput(o)),
              ],
            ),
          ),
          for (final m in result.messages) MessageTile(m),
          if (result.curve != null)
            SectionCard(
              title: 'Gráfica',
              icon: Icons.show_chart,
              child: CurveChart(curve: result.curve!),
            ),
          SectionCard(
            title: 'Experimenta',
            icon: Icons.science_outlined,
            child: BulletList(
              sim.guidingQuestions,
              icon: Icons.help_outline,
            ),
          ),
          SectionCard(
            title: 'Modelo y supuestos',
            icon: Icons.rule,
            child: Text(
              '${sim.assumptions} Es un modelo didáctico simplificado: el '
              'comportamiento real puede variar según la hoja de datos.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterControl extends StatelessWidget {
  const _ParameterControl({
    required this.parameter,
    required this.value,
    required this.onSlider,
    required this.onOption,
  });

  final SimParameter parameter;
  final double value;
  final ValueChanged<double> onSlider;
  final ValueChanged<int> onOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = parameter;
    final labels = p.optionLabels;
    if (labels != null) {
      final selected = value.round();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (var i = 0; i < labels.length; i++)
                  ChoiceChip(
                    label: Text(labels[i]),
                    selected: selected == i,
                    onSelected: (_) => onOption(i),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final display = EngFormat.parameter(value, p.unit, decimals: p.decimals);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(p.label, style: theme.textTheme.labelLarge)),
              Text(
                display,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: p.toSliderPosition(value),
            onChanged: onSlider,
            semanticFormatterCallback: (_) => '${p.label}: $display',
          ),
        ],
      ),
    );
  }
}

class _OutputTile extends StatelessWidget {
  const _OutputTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
