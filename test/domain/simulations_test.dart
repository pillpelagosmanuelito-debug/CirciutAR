import 'package:circuitar/domain/simulation/active_simulations.dart';
import 'package:circuitar/domain/simulation/passive_simulations.dart';
import 'package:circuitar/domain/simulation/semiconductor_simulations.dart';
import 'package:circuitar/domain/simulation/sensor_simulations.dart';
import 'package:circuitar/domain/simulation/simulation.dart';
import 'package:circuitar/domain/simulation/simulation_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Valores calibrados con la implementación de referencia en
/// `tools/reference_values.py`.
void main() {
  bool hasLevel(SimResult r, MessageLevel level) =>
      r.messages.any((m) => m.level == level);

  group('Registro de simulaciones', () {
    test('los identificadores son únicos', () {
      final ids = SimulationRegistry.all.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('todas evalúan con sus valores por defecto y en los extremos', () {
      for (final sim in SimulationRegistry.all) {
        final inputsSets = <Map<String, double>>[
          sim.defaults,
          {for (final p in sim.parameters) p.key: p.min},
          {for (final p in sim.parameters) p.key: p.max},
        ];
        for (final inputs in inputsSets) {
          final r = sim.evaluate(inputs);
          expect(r.outputs, isNotEmpty, reason: sim.id);
          expect(r.messages, isNotEmpty, reason: sim.id);
          for (final o in r.outputs) {
            expect(o.value.isFinite, isTrue, reason: '${sim.id}.${o.key}');
          }
          for (final p in r.curve?.points ?? const <CurvePoint>[]) {
            expect(p.x.isFinite && p.y.isFinite, isTrue, reason: sim.id);
          }
        }
      }
    });

    test('byId lanza error ante un identificador desconocido', () {
      expect(
        () => const SimulationRegistry().byId('no_existe'),
        throwsArgumentError,
      );
    });
  });

  group('SimParameter', () {
    const log = SimParameter(
      key: 'r',
      label: 'R',
      unit: 'Ω',
      min: 10,
      max: 10000,
      defaultValue: 100,
      logarithmic: true,
    );
    const discrete = SimParameter(
      key: 'm',
      label: 'Modo',
      unit: '',
      min: 0,
      max: 2,
      defaultValue: 0,
      optionLabels: ['A', 'B', 'C'],
    );

    test('la escala logarítmica es reversible', () {
      expect(log.toSliderPosition(100), closeTo(1 / 3, 1e-9));
      expect(log.fromSliderPosition(1 / 3), closeTo(100, 1e-6));
      expect(log.fromSliderPosition(-1), closeTo(10, 1e-9));
      expect(log.fromSliderPosition(2), closeTo(10000, 1e-6));
    });

    test('los parámetros discretos se redondean', () {
      expect(discrete.fromSliderPosition(0.7), 1);
      expect(discrete.isDiscrete, isTrue);
    });
  });

  group('Pasivos', () {
    test('resistor: 12 V sobre 470 Ω', () {
      final r = const OhmPowerSimulation()
          .evaluate({'v': 12, 'r': 470, 'rating': 0.25});
      expect(r.value('i'), closeTo(0.0255319, 1e-6));
      expect(r.value('p'), closeTo(0.3063830, 1e-6));
      expect(hasLevel(r, MessageLevel.danger), isTrue);
    });

    test('resistor con margen térmico', () {
      final r = const OhmPowerSimulation()
          .evaluate({'v': 5, 'r': 1000, 'rating': 0.25});
      expect(r.value('usage'), closeTo(10, 1e-9));
      expect(hasLevel(r, MessageLevel.success), isTrue);
    });

    test('potenciómetro con carga de 1 kΩ', () {
      final r = const PotentiometerDividerSimulation()
          .evaluate({'vin': 5, 'rpot': 10000, 'pos': 50, 'rload': 1000});
      expect(r.value('ideal'), closeTo(2.5, 1e-9));
      expect(r.value('vout'), closeTo(0.7142857, 1e-6));
      expect(r.value('error'), greaterThan(5));
      expect(hasLevel(r, MessageLevel.warning), isTrue);
    });

    test('potenciómetro casi sin carga', () {
      final r = const PotentiometerDividerSimulation()
          .evaluate({'vin': 5, 'rpot': 10000, 'pos': 50, 'rload': 1000000});
      expect(r.value('vout'), closeTo(2.4937656, 1e-6));
    });

    test('potenciómetro en los extremos', () {
      expect(
        PotentiometerDividerSimulation.loadedOutput(
            vin: 5, rpot: 1000, alpha: 0, rload: 100),
        0,
      );
      expect(
        PotentiometerDividerSimulation.loadedOutput(
            vin: 5, rpot: 1000, alpha: 1, rload: 100),
        5,
      );
    });

    test('RC: τ = 1 s y 63.2 % en una constante de tiempo', () {
      final r = const RcChargeSimulation()
          .evaluate({'vs': 5, 'r': 10000, 'c': 100, 'tau': 1});
      expect(r.value('tau'), closeTo(1.0, 1e-12));
      expect(r.value('vc'), closeTo(3.1606028, 1e-6));
      expect(r.value('t99'), closeTo(4.6051702, 1e-6));
    });

    test('filtro de rizado de onda completa', () {
      final r = const RippleFilterSimulation()
          .evaluate({'vp': 12, 'iload': 500, 'c': 2200, 'mode': 1});
      expect(r.value('ripple'), closeTo(1.8939394, 1e-6));
      expect(r.value('rating'), 25);
    });

    test('media onda duplica el rizado y alerta', () {
      final r = const RippleFilterSimulation()
          .evaluate({'vp': 12, 'iload': 500, 'c': 1000, 'mode': 0});
      expect(r.value('ripple'), closeTo(8.3333333, 1e-6));
      expect(hasLevel(r, MessageLevel.warning), isTrue);
    });

    test('RL: τ = L/R y corriente en 1 τ', () {
      final r = const RlCurrentSimulation()
          .evaluate({'vs': 12, 'r': 10, 'l': 100, 'tau': 1});
      expect(r.value('tau'), closeTo(0.01, 1e-12));
      expect(r.value('ifinal'), closeTo(1.2, 1e-12));
      expect(r.value('i'), closeTo(0.7585447, 1e-6));
      expect(hasLevel(r, MessageLevel.danger), isTrue);
    });
  });

  group('Semiconductores', () {
    test('diodo: 5 V con 1 kΩ (coincide con CircuitLab Academy)', () {
      final r = const DiodeForwardSimulation().evaluate({'vs': 5, 'r': 1000});
      expect(r.value('vd'), closeTo(0.6925, 1e-4));
      expect(r.value('id'), closeTo(0.0043075, 1e-6));
      expect(r.state, 'Polarización directa');
    });

    test('diodo en inversa casi no conduce', () {
      final r = const DiodeForwardSimulation().evaluate({'vs': -5, 'r': 1000});
      expect(r.value('id').abs(), lessThan(1e-12));
      expect(r.state, 'Polarización inversa');
      expect(r.curve?.marker, isNull);
    });

    test('Zener regulando', () {
      final r = const ZenerRegulatorSimulation()
          .evaluate({'vin': 12, 'rs': 220, 'rl': 1000});
      expect(r.value('vout'), closeTo(5.1, 1e-12));
      expect(r.value('iz'), closeTo(0.0262636, 1e-6));
      expect(r.state, 'Regulando');
    });

    test('Zener sin regulación con carga pesada', () {
      final r = const ZenerRegulatorSimulation()
          .evaluate({'vin': 12, 'rs': 220, 'rl': 100});
      expect(r.value('vout'), closeTo(3.75, 1e-9));
      expect(r.value('iz'), 0);
      expect(r.state, 'Sin regulación');
    });

    test('Zener sobrecargado', () {
      final r = const ZenerRegulatorSimulation()
          .evaluate({'vin': 20, 'rs': 50, 'rl': 10000});
      expect(r.value('pz'), greaterThan(0.5));
      expect(r.state, 'Sobrecarga térmica');
    });

    test('LED rojo a 5 V y 15 mA', () {
      final r = const LedResistorSimulation()
          .evaluate({'vcc': 5, 'color': 0, 'if': 15});
      expect(r.value('r_calc'), closeTo(200, 1e-9));
      expect(r.value('r_std'), 220);
      expect(r.value('i_real'), closeTo(3 / 220, 1e-9));
    });

    test('LED azul con 3 V no enciende', () {
      final r = const LedResistorSimulation()
          .evaluate({'vcc': 3, 'color': 3, 'if': 10});
      expect(r.state, 'LED apagado');
      expect(hasLevel(r, MessageLevel.danger), isTrue);
    });

    test('BJT saturado', () {
      final r = const BjtSwitchSimulation().evaluate(
          {'vin': 5, 'rb': 10000, 'rc': 1000, 'vcc': 12, 'beta': 100});
      expect(r.state, 'Saturación');
      expect(r.value('ib'), closeTo(0.00043, 1e-12));
      expect(r.value('ic'), closeTo(0.0118, 1e-12));
      expect(r.value('vce'), closeTo(0.2, 1e-12));
    });

    test('BJT en zona activa con Rb grande', () {
      final r = const BjtSwitchSimulation().evaluate(
          {'vin': 5, 'rb': 1000000, 'rc': 1000, 'vcc': 12, 'beta': 100});
      expect(r.state, 'Zona activa');
      expect(r.value('vce'), closeTo(11.57, 1e-9));
    });

    test('BJT en corte', () {
      final r = const BjtSwitchSimulation().evaluate(
          {'vin': 0.5, 'rb': 10000, 'rc': 1000, 'vcc': 12, 'beta': 100});
      expect(r.state, 'Corte');
      expect(r.value('ic'), 0);
      expect(r.value('vce'), 12);
    });

    test('MOSFET con 3.3 V y Vth de 2 V conduce parcialmente', () {
      final r = const MosfetSwitchSimulation()
          .evaluate({'vgs': 3.3, 'vth': 2, 'vdd': 12, 'rl': 12});
      expect(r.state, startsWith('Saturación'));
      expect(r.value('id'), closeTo(0.845, 1e-9));
      expect(hasLevel(r, MessageLevel.danger), isTrue);
    });

    test('MOSFET con 5 V conduce plenamente', () {
      final r = const MosfetSwitchSimulation()
          .evaluate({'vgs': 5, 'vth': 2, 'vdd': 12, 'rl': 12});
      expect(r.state, startsWith('Óhmica'));
      expect(r.value('id'), closeTo(0.989011, 1e-6));
      expect(r.value('vds'), closeTo(0.1318681, 1e-6));
    });

    test('MOSFET en corte', () {
      final r = const MosfetSwitchSimulation()
          .evaluate({'vgs': 1, 'vth': 2, 'vdd': 12, 'rl': 12});
      expect(r.state, 'Corte');
      expect(r.value('id'), 0);
    });
  });

  group('Activos', () {
    test('no inversor con ganancia 11', () {
      final r = const OpAmpSimulation().evaluate(
          {'mode': 1, 'vin': 0.5, 'rf': 10000, 'rin': 1000, 'vcc': 12});
      expect(r.value('gain'), closeTo(11, 1e-12));
      expect(r.value('vout'), closeTo(5.5, 1e-12));
      expect(r.state, 'Zona lineal');
    });

    test('inversor invierte el signo', () {
      final r = const OpAmpSimulation().evaluate(
          {'mode': 0, 'vin': 0.5, 'rf': 10000, 'rin': 1000, 'vcc': 12});
      expect(r.value('vout'), closeTo(-5, 1e-12));
    });

    test('saturación en 10.5 V con ±12 V', () {
      final r = const OpAmpSimulation().evaluate(
          {'mode': 1, 'vin': 1.5, 'rf': 10000, 'rin': 1000, 'vcc': 12});
      expect(r.value('vout'), closeTo(10.5, 1e-12));
      expect(r.state, 'Saturación');
    });

    test('7805 con 12 V y 500 mA necesita disipador', () {
      final r = const LinearRegulatorSimulation()
          .evaluate({'vin': 12, 'iload': 500});
      expect(r.value('vout'), 5);
      expect(r.value('p'), closeTo(3.5, 1e-12));
      expect(r.value('tj'), closeTo(252.5, 1e-9));
      expect(r.state, 'Protección térmica');
    });

    test('7805 fuera de regulación con 6 V', () {
      final r = const LinearRegulatorSimulation()
          .evaluate({'vin': 6, 'iload': 100});
      expect(r.value('vout'), closeTo(4, 1e-12));
      expect(r.state, 'Fuera de regulación');
    });

    test('555 astable', () {
      final r = const Timer555Simulation()
          .evaluate({'r1': 10000, 'r2': 68000, 'c': 10});
      expect(r.value('f'), closeTo(0.9883572, 1e-6));
      expect(r.value('duty'), closeTo(53.4246575, 1e-6));
      expect(
        Timer555Simulation.frequency(r1: 1000, r2: 10000, c: 10e-6),
        closeTo(6.8714354, 1e-6),
      );
    });
  });

  group('Sensores', () {
    test('LDR a 10 lx vale 10 kΩ', () {
      final r = const LdrDividerSimulation()
          .evaluate({'lux': 10, 'rf': 10000, 'vcc': 5});
      expect(r.value('rldr'), closeTo(10000, 1e-6));
      expect(r.value('vout'), closeTo(2.5, 1e-9));
    });

    test('LDR: más luz, más tensión', () {
      final dark = LdrDividerSimulation.output(lux: 5, rf: 10000, vcc: 5);
      final bright = LdrDividerSimulation.output(lux: 500, rf: 10000, vcc: 5);
      expect(bright, greaterThan(dark));
    });

    test('NTC con modelo Beta', () {
      expect(NtcDividerSimulation.resistance(25, 3950), closeTo(10000, 1e-6));
      expect(NtcDividerSimulation.resistance(0, 3950), closeTo(33620.6, 0.1));
      final r = const NtcDividerSimulation()
          .evaluate({'t': 100, 'beta': 3950, 'rf': 10000});
      expect(r.value('vout'), closeTo(4.6739806, 1e-6));
    });

    test('LM35 a 37 °C', () {
      final r = const Lm35Simulation().evaluate({'t': 37, 'vref': 0});
      expect(r.value('vout'), closeTo(0.37, 1e-12));
      expect(r.value('code'), 76);
      expect(r.value('resolution'), closeTo(0.4887586, 1e-6));
    });

    test('LM35 bajo 2 °C advierte', () {
      final r = const Lm35Simulation().evaluate({'t': 1, 'vref': 1});
      expect(hasLevel(r, MessageLevel.warning), isTrue);
    });

    test('HC-SR04 a 50 cm y 20 °C', () {
      final r = const UltrasonicSimulation().evaluate({'d': 50, 't': 20});
      expect(r.value('c'), closeTo(343.42, 1e-9));
      expect(r.value('echo'), closeTo(0.0029118863, 1e-9));
    });

    test('HC-SR04 a 35 °C mide de menos', () {
      final r = const UltrasonicSimulation().evaluate({'d': 100, 't': 35});
      expect(r.value('estimated'), closeTo(97.3022, 1e-3));
      expect(r.value('error'), lessThan(-1));
    });
  });
}
