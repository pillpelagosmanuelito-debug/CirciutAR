import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/simulation/simulation.dart';
import '../../providers/providers.dart';

class SimulationState {
  const SimulationState({
    required this.simulation,
    required this.values,
    required this.result,
    this.touched = false,
  });

  final ComponentSimulation simulation;
  final Map<String, double> values;
  final SimResult result;

  /// Verdadero cuando el estudiante ya modificó algún parámetro.
  final bool touched;

  double valueOf(String key) =>
      values[key] ??
      simulation.parameters.firstWhere((p) => p.key == key).defaultValue;
}

/// ViewModel del laboratorio: mantiene los parámetros y recalcula al instante.
class SimulationViewModel
    extends AutoDisposeFamilyNotifier<SimulationState, String> {
  @override
  SimulationState build(String arg) {
    final sim = ref.watch(simulationRegistryProvider).byId(arg);
    final values = sim.defaults;
    return SimulationState(
      simulation: sim,
      values: values,
      result: sim.evaluate(values),
    );
  }

  void setValue(String key, double value) {
    final sim = state.simulation;
    final param = sim.parameters.firstWhere((p) => p.key == key);
    final values = Map<String, double>.of(state.values)
      ..[key] = param.clamp(value);
    state = SimulationState(
      simulation: sim,
      values: values,
      result: sim.evaluate(values),
      touched: true,
    );
    unawaited(ref.read(progressProvider.notifier).markSimulationUsed(sim.id));
  }

  /// Ajusta un parámetro desde la posición normalizada de un control.
  void setFromSlider(String key, double position) {
    final param = state.simulation.parameters.firstWhere((p) => p.key == key);
    setValue(key, param.fromSliderPosition(position));
  }

  void reset() {
    final sim = state.simulation;
    final values = sim.defaults;
    state = SimulationState(
      simulation: sim,
      values: values,
      result: sim.evaluate(values),
    );
  }
}

final simulationViewModelProvider = NotifierProvider.autoDispose
    .family<SimulationViewModel, SimulationState, String>(
  SimulationViewModel.new,
);
