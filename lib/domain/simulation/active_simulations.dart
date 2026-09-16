import 'dart:math' as math;

import 'simulation.dart';

/// Amplificador operacional en configuración inversora o no inversora.
class OpAmpSimulation extends ComponentSimulation {
  const OpAmpSimulation();

  /// Margen entre la salida y la alimentación en un amplificador que no es
  /// de salida completa (rail-to-rail), como el LM358 o el 741.
  static const double headroom = 1.5;

  @override
  String get id => 'opamp_amplifier';

  @override
  String get title => 'Amplificador operacional';

  @override
  String get circuit =>
      'Amplificador operacional con resistor de entrada Rin y de '
      'realimentación Rf, alimentado con ±Vcc.';

  @override
  String get learningGoal =>
      'Calcular la ganancia de cada configuración y descubrir que la salida '
      'no puede superar los límites de alimentación.';

  @override
  String get assumptions =>
      'Amplificador ideal (ganancia de lazo abierto infinita) con saturación '
      'a 1.5 V de cada alimentación.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'mode',
          label: 'Configuración',
          unit: '',
          min: 0,
          max: 1,
          defaultValue: 1,
          decimals: 0,
          optionLabels: ['Inversora', 'No inversora'],
        ),
        SimParameter(
          key: 'vin',
          label: 'Tensión de entrada',
          unit: 'V',
          min: -2,
          max: 2,
          defaultValue: 0.5,
          decimals: 2,
        ),
        SimParameter(
          key: 'rf',
          label: 'Resistor de realimentación Rf',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'rin',
          label: 'Resistor de entrada Rin',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 1000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'vcc',
          label: 'Alimentación ±Vcc',
          unit: 'V',
          min: 5,
          max: 15,
          defaultValue: 12,
          decimals: 1,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Con ganancia 11, ¿qué entrada máxima evita la saturación con ±12 V?',
        '¿Qué diferencia de signo hay entre ambas configuraciones?',
        '¿Qué configuración conviene para no cargar a un sensor?',
      ];

  static double gain({
    required bool inverting,
    required double rf,
    required double rin,
  }) =>
      inverting ? -rf / rin : 1 + rf / rin;

  static double output({
    required double gain,
    required double vin,
    required double vcc,
  }) {
    final limit = vcc - headroom;
    return (gain * vin).clamp(-limit, limit).toDouble();
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final inverting = read(inputs, 'mode') < 0.5;
    final vin = read(inputs, 'vin');
    final rf = read(inputs, 'rf');
    final rin = read(inputs, 'rin');
    final vcc = read(inputs, 'vcc');
    final g = gain(inverting: inverting, rf: rf, rin: rin);
    final ideal = g * vin;
    final vout = output(gain: g, vin: vin, vcc: vcc);
    final saturated = (ideal - vout).abs() > 1e-9;

    final messages = <SimMessage>[];
    if (saturated) {
      messages.add(SimMessage(
        MessageLevel.danger,
        'Saturación: la salida ideal sería ${ideal.toStringAsFixed(2)} V, '
        'pero no puede superar ±${(vcc - headroom).toStringAsFixed(1)} V. '
        'Reduce la ganancia o la entrada.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Zona lineal: la salida es proporcional a la entrada.',
      ));
    }
    messages.add(SimMessage(
      MessageLevel.info,
      inverting
          ? 'Impedancia de entrada ≈ Rin: la configuración inversora carga a '
              'la fuente de señal.'
          : 'Impedancia de entrada muy alta: ideal para no cargar a un sensor.',
    ));

    final points = linspace(-2, 2, 41)
        .map((x) => CurvePoint(x, output(gain: g, vin: x, vcc: vcc)))
        .toList();

    return SimResult(
      state: saturated ? 'Saturación' : 'Zona lineal',
      outputs: [
        SimOutput(key: 'gain', label: 'Ganancia', value: g, unit: '', plain: true),
        SimOutput(key: 'vout', label: 'Tensión de salida', value: vout, unit: 'V'),
        SimOutput(key: 'ideal', label: 'Salida ideal sin límites', value: ideal, unit: 'V'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Característica de transferencia',
        xLabel: 'Entrada (V)',
        yLabel: 'Salida (V)',
        points: points,
        marker: CurvePoint(vin, vout),
      ),
    );
  }
}

/// Regulador lineal de 5 V (familia 7805).
class LinearRegulatorSimulation extends ComponentSimulation {
  const LinearRegulatorSimulation();

  static const double vOut = 5;
  static const double dropout = 2;
  static const double maxCurrent = 1.5;
  static const double maxInput = 35;

  /// Resistencia térmica unión-ambiente del TO-220 sin disipador (°C/W).
  static const double thetaJa = 65;
  static const double ambient = 25;
  static const double maxJunction = 125;

  @override
  String get id => 'regulator_7805';

  @override
  String get title => 'Regulador lineal 7805';

  @override
  String get circuit =>
      'Un 7805 en encapsulado TO-220, sin disipador, alimenta una carga.';

  @override
  String get learningGoal =>
      'Comprender que un regulador lineal convierte en calor la diferencia '
      'de tensión y decidir cuándo necesita disipador.';

  @override
  String get assumptions =>
      'Tensión de caída mínima de 2 V, corriente máxima de 1.5 A, θJA = '
      '65 °C/W, ambiente de 25 °C y corriente de reposo despreciable.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vin',
          label: 'Tensión de entrada',
          unit: 'V',
          min: 5,
          max: 35,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'iload',
          label: 'Corriente de la carga',
          unit: 'mA',
          min: 10,
          max: 1500,
          defaultValue: 500,
          logarithmic: true,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Qué entrada mínima necesita para entregar 5 V?',
        'Con 500 mA, ¿qué entrada máxima evita el disipador?',
        '¿Por qué alimentar un 7805 con 24 V es una mala idea?',
      ];

  static double dissipation({required double vin, required double current}) {
    final out = vin >= vOut + dropout ? vOut : math.max(vin - dropout, 0.0);
    return (vin - out) * current;
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vin = read(inputs, 'vin');
    final i = read(inputs, 'iload') / 1000;
    final regulating = vin >= vOut + dropout;
    final out = regulating ? vOut : math.max(vin - dropout, 0.0);
    final p = (vin - out) * i;
    final tj = ambient + p * thetaJa;
    final efficiency = out * i / (vin * i) * 100;

    final messages = <SimMessage>[];
    String state;
    if (!regulating) {
      state = 'Fuera de regulación';
      messages.add(const SimMessage(
        MessageLevel.warning,
        'La entrada es menor que 7 V (5 V + caída mínima): la salida deja de '
        'estar regulada.',
      ));
    } else if (tj > maxJunction) {
      state = 'Protección térmica';
      messages.add(SimMessage(
        MessageLevel.danger,
        'Sin disipador la unión llegaría a ${tj.toStringAsFixed(0)} °C: el '
        'regulador se apagará por protección térmica. Agrega disipador o '
        'reduce la tensión de entrada.',
      ));
    } else if (p > 1) {
      state = 'Regulando (caliente)';
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Disipa más de 1 W: funcionará muy caliente. Se recomienda disipador.',
      ));
    } else {
      state = 'Regulando';
      messages.add(const SimMessage(
        MessageLevel.success,
        'Regula con temperatura aceptable sin disipador.',
      ));
    }
    if (efficiency < 50) {
      messages.add(const SimMessage(
        MessageLevel.info,
        'Eficiencia menor al 50 %: para esta diferencia de tensión conviene un '
        'convertidor conmutado (buck).',
      ));
    }

    final points = linspace(5, 35, 31)
        .map((x) => CurvePoint(x, dissipation(vin: x, current: i)))
        .toList();

    return SimResult(
      state: state,
      outputs: [
        SimOutput(key: 'vout', label: 'Tensión de salida', value: out, unit: 'V'),
        SimOutput(key: 'p', label: 'Potencia disipada', value: p, unit: 'W'),
        SimOutput(
          key: 'tj',
          label: 'Temperatura de unión estimada',
          value: tj,
          unit: '°C',
          plain: true,
        ),
        SimOutput(
          key: 'eff',
          label: 'Eficiencia',
          value: efficiency,
          unit: '%',
          plain: true,
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Calor según la tensión de entrada',
        xLabel: 'Entrada (V)',
        yLabel: 'Potencia disipada (W)',
        points: points,
        marker: CurvePoint(vin, p),
      ),
    );
  }
}

/// Temporizador 555 en modo astable.
class Timer555Simulation extends ComponentSimulation {
  const Timer555Simulation();

  @override
  String get id => 'timer555_astable';

  @override
  String get title => 'Temporizador 555 astable';

  @override
  String get circuit =>
      '555 en modo astable con R1 entre la alimentación y descarga, R2 entre '
      'descarga y umbral, y C a tierra.';

  @override
  String get learningGoal =>
      'Calcular la frecuencia y el ciclo de trabajo, y ver por qué este '
      'circuito no puede dar exactamente 50 %.';

  @override
  String get assumptions =>
      'Ecuaciones clásicas: tH = 0.693·(R1 + R2)·C, tL = 0.693·R2·C.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'r1',
          label: 'R1',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'r2',
          label: 'R2',
          unit: 'Ω',
          min: 1000,
          max: 1000000,
          defaultValue: 68000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'c',
          label: 'Capacitor C',
          unit: 'µF',
          min: 0.001,
          max: 100,
          defaultValue: 10,
          logarithmic: true,
          decimals: 3,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Qué componente cambiarías para que un LED parpadee una vez por segundo?',
        '¿Qué pasa con el ciclo de trabajo si R1 es mucho menor que R2?',
        '¿A partir de qué frecuencia el ojo ya no percibe el parpadeo?',
      ];

  static double frequency({
    required double r1,
    required double r2,
    required double c,
  }) =>
      1 / (0.693 * (r1 + 2 * r2) * c);

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final r1 = read(inputs, 'r1');
    final r2 = read(inputs, 'r2');
    final c = read(inputs, 'c') * 1e-6;
    final tHigh = 0.693 * (r1 + r2) * c;
    final tLow = 0.693 * r2 * c;
    final period = tHigh + tLow;
    final f = 1 / period;
    final duty = tHigh / period * 100;

    final messages = <SimMessage>[
      const SimMessage(
        MessageLevel.info,
        'En esta configuración el tiempo en alto siempre supera al tiempo en '
        'bajo. Para 50 % se agrega un diodo en paralelo con R2.',
      ),
    ];
    if (f > 20000) {
      messages.add(const SimMessage(
        MessageLevel.info,
        'Por encima de 20 kHz: la señal ya no es audible en un zumbador.',
      ));
    } else if (f > 25) {
      messages.add(const SimMessage(
        MessageLevel.info,
        'Por encima de unos 25 Hz, un LED parece encendido de forma continua.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Frecuencia baja: el parpadeo de un LED es visible.',
      ));
    }

    // Dos periodos de la onda cuadrada, normalizados al periodo.
    final hi = tHigh / period;
    final points = <CurvePoint>[
      const CurvePoint(0, 0),
      const CurvePoint(0, 1),
      CurvePoint(hi, 1),
      CurvePoint(hi, 0),
      const CurvePoint(1, 0),
      const CurvePoint(1, 1),
      CurvePoint(1 + hi, 1),
      CurvePoint(1 + hi, 0),
      const CurvePoint(2, 0),
    ];

    return SimResult(
      outputs: [
        SimOutput(key: 'f', label: 'Frecuencia', value: f, unit: 'Hz'),
        SimOutput(key: 'period', label: 'Periodo', value: period, unit: 's'),
        SimOutput(key: 'thigh', label: 'Tiempo en alto', value: tHigh, unit: 's'),
        SimOutput(key: 'tlow', label: 'Tiempo en bajo', value: tLow, unit: 's'),
        SimOutput(
          key: 'duty',
          label: 'Ciclo de trabajo',
          value: duty,
          unit: '%',
          plain: true,
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida (dos periodos)',
        xLabel: 'Tiempo (periodos)',
        yLabel: 'Nivel lógico',
        points: points,
      ),
    );
  }
}
