import 'active_simulations.dart';
import 'passive_simulations.dart';
import 'semiconductor_simulations.dart';
import 'sensor_simulations.dart';
import 'simulation.dart';

/// Catálogo de simulaciones disponibles, indexado por identificador.
class SimulationRegistry {
  const SimulationRegistry();

  static const List<ComponentSimulation> all = [
    OhmPowerSimulation(),
    PotentiometerDividerSimulation(),
    RcChargeSimulation(),
    RippleFilterSimulation(),
    RlCurrentSimulation(),
    DiodeForwardSimulation(),
    ZenerRegulatorSimulation(),
    LedResistorSimulation(),
    BjtSwitchSimulation(),
    MosfetSwitchSimulation(),
    OpAmpSimulation(),
    LinearRegulatorSimulation(),
    Timer555Simulation(),
    LdrDividerSimulation(),
    NtcDividerSimulation(),
    Lm35Simulation(),
    UltrasonicSimulation(),
  ];

  ComponentSimulation? find(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  ComponentSimulation byId(String id) {
    final s = find(id);
    if (s == null) throw ArgumentError('Simulación desconocida: $id');
    return s;
  }
}
