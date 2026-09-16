import 'dart:math' as math;

import 'simulation.dart';
import 'standard_values.dart';

/// Resistor: ley de Ohm y potencia disipada frente a la potencia nominal.
class OhmPowerSimulation extends ComponentSimulation {
  const OhmPowerSimulation();

  @override
  String get id => 'ohm_power';

  @override
  String get title => 'Resistor: corriente y potencia';

  @override
  String get circuit =>
      'Una fuente de tensión continua alimenta un único resistor.';

  @override
  String get learningGoal =>
      'Comprobar que el valor en ohmios no basta: la potencia nominal también '
      'decide si el resistor sirve.';

  @override
  String get assumptions =>
      'Resistor ideal a temperatura ambiente; se ignora la tolerancia.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'v',
          label: 'Tensión de la fuente',
          unit: 'V',
          min: 0,
          max: 24,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'r',
          label: 'Resistencia',
          unit: 'Ω',
          min: 10,
          max: 10000,
          defaultValue: 470,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'rating',
          label: 'Potencia nominal',
          unit: 'W',
          min: 0.125,
          max: 2,
          defaultValue: 0.25,
          logarithmic: true,
          decimals: 3,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Qué valor mínimo de resistencia soporta un resistor de 1/4 W con 12 V?',
        'Si duplicas la tensión, ¿cuánto aumenta la potencia?',
        '¿Por qué conviene trabajar por debajo del 50 % de la potencia nominal?',
      ];

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final v = read(inputs, 'v');
    final r = read(inputs, 'r');
    final rating = read(inputs, 'rating');
    final i = v / r;
    final p = v * v / r;
    final usage = p / rating * 100;

    final messages = <SimMessage>[];
    if (p > rating) {
      messages.add(const SimMessage(
        MessageLevel.danger,
        'El resistor disipa más de su potencia nominal: se sobrecalentará y '
        'puede quemarse. Usa uno de mayor potencia o aumenta la resistencia.',
      ));
    } else if (usage > 50) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Supera el 50 % de la potencia nominal. Regla práctica: elige un '
        'resistor con al menos el doble de la potencia calculada.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Margen térmico adecuado para operación continua.',
      ));
    }

    final points = linspace(0, 24, 25)
        .map((x) => CurvePoint(x, x / r * 1000))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'i', label: 'Corriente', value: i, unit: 'A'),
        SimOutput(key: 'p', label: 'Potencia disipada', value: p, unit: 'W'),
        SimOutput(
          key: 'usage',
          label: 'Uso de la potencia nominal',
          value: usage,
          unit: '%',
          plain: true,
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Recta de Ohm del resistor',
        xLabel: 'Tensión (V)',
        yLabel: 'Corriente (mA)',
        points: points,
        marker: CurvePoint(v, i * 1000),
      ),
    );
  }
}

/// Potenciómetro como divisor de tensión, con efecto de carga.
class PotentiometerDividerSimulation extends ComponentSimulation {
  const PotentiometerDividerSimulation();

  @override
  String get id => 'pot_divider';

  @override
  String get title => 'Potenciómetro: divisor y efecto de carga';

  @override
  String get circuit =>
      'Los extremos del potenciómetro van a la fuente y a tierra; el cursor '
      'alimenta una carga conectada a tierra.';

  @override
  String get learningGoal =>
      'Descubrir que una carga de baja resistencia altera la tensión del '
      'divisor y que el potenciómetro no es una fuente de alimentación.';

  @override
  String get assumptions =>
      'Potenciómetro lineal ideal; la carga es puramente resistiva.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vin',
          label: 'Tensión de entrada',
          unit: 'V',
          min: 0,
          max: 12,
          defaultValue: 5,
          decimals: 1,
        ),
        SimParameter(
          key: 'rpot',
          label: 'Resistencia total del potenciómetro',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'pos',
          label: 'Posición del cursor',
          unit: '%',
          min: 0,
          max: 100,
          defaultValue: 50,
          decimals: 0,
        ),
        SimParameter(
          key: 'rload',
          label: 'Resistencia de la carga',
          unit: 'Ω',
          min: 100,
          max: 1000000,
          defaultValue: 1000000,
          logarithmic: true,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Con el cursor al 50 %, baja la carga a 1 kΩ. ¿Qué pasa con la salida?',
        '¿Qué relación debe existir entre la carga y el potenciómetro para que '
            'el error sea menor al 5 %?',
        '¿Conviene alimentar un motor desde el cursor? ¿Por qué?',
      ];

  /// Tensión de salida con carga, en voltios.
  static double loadedOutput({
    required double vin,
    required double rpot,
    required double alpha,
    required double rload,
  }) {
    if (alpha <= 0) return 0;
    final upper = (1 - alpha) * rpot;
    final lowerRaw = alpha * rpot;
    final lower = lowerRaw * rload / (lowerRaw + rload);
    if (upper <= 0) return vin;
    return vin * lower / (upper + lower);
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vin = read(inputs, 'vin');
    final rpot = read(inputs, 'rpot');
    final alpha = read(inputs, 'pos') / 100;
    final rload = read(inputs, 'rload');

    final ideal = vin * alpha;
    final loaded =
        loadedOutput(vin: vin, rpot: rpot, alpha: alpha, rload: rload);
    final error = ideal > 0 ? (ideal - loaded) / ideal * 100 : 0.0;

    final messages = <SimMessage>[];
    if (error > 5) {
      messages.add(SimMessage(
        MessageLevel.warning,
        'Efecto de carga: la salida cae ${error.toStringAsFixed(1)} % respecto '
        'del valor ideal. Usa una carga al menos 10 veces mayor que el '
        'potenciómetro o intercala un seguidor de tensión.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'La carga es suficientemente alta: el divisor se comporta casi ideal.',
      ));
    }

    final points = linspace(0, 100, 41)
        .map((x) => CurvePoint(
              x,
              loadedOutput(vin: vin, rpot: rpot, alpha: x / 100, rload: rload),
            ))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'ideal', label: 'Salida sin carga', value: ideal, unit: 'V'),
        SimOutput(key: 'vout', label: 'Salida con carga', value: loaded, unit: 'V'),
        SimOutput(
          key: 'error',
          label: 'Error por efecto de carga',
          value: error,
          unit: '%',
          plain: true,
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida según la posición del cursor',
        xLabel: 'Posición (%)',
        yLabel: 'Salida (V)',
        points: points,
        marker: CurvePoint(alpha * 100, loaded),
      ),
    );
  }
}

/// Capacitor cerámico en un circuito RC: carga exponencial.
class RcChargeSimulation extends ComponentSimulation {
  const RcChargeSimulation();

  @override
  String get id => 'rc_charge';

  @override
  String get title => 'Capacitor: carga en un circuito RC';

  @override
  String get circuit =>
      'Una fuente escalón carga un capacitor a través de un resistor en serie.';

  @override
  String get learningGoal =>
      'Relacionar la constante de tiempo τ = RC con la rapidez de carga y '
      'reconocer que el capacitor no se carga de golpe.';

  @override
  String get assumptions =>
      'Capacitor ideal inicialmente descargado; sin fugas ni resistencia serie.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vs',
          label: 'Tensión de la fuente',
          unit: 'V',
          min: 1,
          max: 24,
          defaultValue: 5,
          decimals: 1,
        ),
        SimParameter(
          key: 'r',
          label: 'Resistencia',
          unit: 'Ω',
          min: 100,
          max: 1000000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'c',
          label: 'Capacitancia',
          unit: 'µF',
          min: 0.001,
          max: 1000,
          defaultValue: 100,
          logarithmic: true,
          decimals: 3,
        ),
        SimParameter(
          key: 'tau',
          label: 'Instante observado',
          unit: 'τ',
          min: 0,
          max: 5,
          defaultValue: 1,
          decimals: 1,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Qué porcentaje de la tensión final alcanza el capacitor en 1 τ?',
        '¿Cuántas constantes de tiempo se consideran «carga completa»?',
        'Si duplicas R, ¿qué pasa con el tiempo de carga?',
      ];

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vs = read(inputs, 'vs');
    final r = read(inputs, 'r');
    final c = read(inputs, 'c') * 1e-6;
    final k = read(inputs, 'tau');
    final tau = r * c;
    final t = k * tau;
    final vc = vs * (1 - math.exp(-k));
    final ic = vs / r * math.exp(-k);

    final messages = <SimMessage>[
      SimMessage(
        MessageLevel.info,
        'En ${k.toStringAsFixed(1)} τ el capacitor alcanza el '
        '${((1 - math.exp(-k)) * 100).toStringAsFixed(1)} % de la tensión final.',
      ),
    ];
    if (tau < 1e-3) {
      messages.add(const SimMessage(
        MessageLevel.info,
        'Constante de tiempo menor que 1 ms: típica de filtros y desacoplo, '
        'donde se usan capacitores cerámicos.',
      ));
    } else if (tau > 10) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Temporización larga: la corriente de fuga de un electrolítico puede '
        'alterar el resultado. Para tiempos precisos usa un temporizador.',
      ));
    }

    final points = linspace(0, 5, 51)
        .map((x) => CurvePoint(x, vs * (1 - math.exp(-x))))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'tau', label: 'Constante de tiempo τ', value: tau, unit: 's'),
        SimOutput(key: 't', label: 'Tiempo transcurrido', value: t, unit: 's'),
        SimOutput(key: 'vc', label: 'Tensión en el capacitor', value: vc, unit: 'V'),
        SimOutput(key: 'ic', label: 'Corriente de carga', value: ic, unit: 'A'),
        SimOutput(
          key: 't99',
          label: 'Tiempo al 99 %',
          value: tau * math.log(100),
          unit: 's',
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Carga del capacitor',
        xLabel: 'Tiempo (en τ)',
        yLabel: 'Tensión (V)',
        points: points,
        marker: CurvePoint(k, vc),
      ),
    );
  }
}

/// Capacitor electrolítico como filtro de una fuente rectificada.
class RippleFilterSimulation extends ComponentSimulation {
  const RippleFilterSimulation();

  /// Frecuencia de la red eléctrica en el Perú.
  static const double mainsFrequency = 60;

  @override
  String get id => 'ripple_filter';

  @override
  String get title => 'Electrolítico: filtro de rizado';

  @override
  String get circuit =>
      'Un rectificador entrega pulsos a un capacitor en paralelo con la carga.';

  @override
  String get learningGoal =>
      'Entender por qué las fuentes usan capacitores electrolíticos de gran '
      'capacidad y cómo se elige su tensión nominal.';

  @override
  String get assumptions =>
      'Red de 60 Hz; aproximación ΔV = I / (f·C); se ignora la caída en los '
      'diodos y la resistencia serie equivalente.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vp',
          label: 'Tensión pico rectificada',
          unit: 'V',
          min: 5,
          max: 30,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'iload',
          label: 'Corriente de la carga',
          unit: 'mA',
          min: 10,
          max: 2000,
          defaultValue: 500,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'c',
          label: 'Capacitancia',
          unit: 'µF',
          min: 100,
          max: 10000,
          defaultValue: 1000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'mode',
          label: 'Rectificación',
          unit: '',
          min: 0,
          max: 1,
          defaultValue: 1,
          decimals: 0,
          optionLabels: ['Media onda', 'Onda completa'],
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Cuánto cambia el rizado al pasar de media onda a onda completa?',
        '¿Qué capacidad necesitas para un rizado menor a 1 V con 500 mA?',
        '¿Por qué la tensión nominal debe superar con margen la tensión pico?',
      ];

  static double ripple({
    required double current,
    required double capacitance,
    required bool fullWave,
  }) {
    final f = mainsFrequency * (fullWave ? 2 : 1);
    return current / (f * capacitance);
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vp = read(inputs, 'vp');
    final i = read(inputs, 'iload') / 1000;
    final c = read(inputs, 'c') * 1e-6;
    final fullWave = read(inputs, 'mode') >= 0.5;
    final dv = ripple(current: i, capacitance: c, fullWave: fullWave);
    final effectiveDv = math.min(dv, vp);
    final vdc = vp - effectiveDv / 2;
    final rating = nextVoltageRating(vp * 1.5);
    final ripplePercent = effectiveDv / vp * 100;

    final messages = <SimMessage>[];
    if (ripplePercent > 10) {
      messages.add(SimMessage(
        MessageLevel.warning,
        'Rizado del ${ripplePercent.toStringAsFixed(1)} %: excesivo para '
        'alimentar un regulador. Aumenta la capacidad o usa onda completa.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Rizado aceptable para alimentar un regulador lineal.',
      ));
    }
    messages.add(SimMessage(
      MessageLevel.info,
      'Tensión nominal recomendada: ${rating.toStringAsFixed(rating % 1 == 0 ? 0 : 1)} V '
      '(al menos 1.5 veces la tensión pico). Respeta la polaridad del '
      'electrolítico.',
    ));

    final points = logspace(100, 10000, 40)
        .map((x) => CurvePoint(
              x,
              ripple(current: i, capacitance: x * 1e-6, fullWave: fullWave),
            ))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'ripple', label: 'Rizado pico a pico', value: effectiveDv, unit: 'V'),
        SimOutput(key: 'vdc', label: 'Tensión media aproximada', value: vdc, unit: 'V'),
        SimOutput(
          key: 'percent',
          label: 'Rizado relativo',
          value: ripplePercent,
          unit: '%',
          plain: true,
        ),
        SimOutput(key: 'rating', label: 'Tensión nominal sugerida', value: rating, unit: 'V'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Rizado según la capacidad',
        xLabel: 'Capacidad (µF)',
        yLabel: 'Rizado (V)',
        points: points,
        marker: CurvePoint(c * 1e6, dv),
      ),
    );
  }
}

/// Inductor en un circuito RL: la corriente no cambia instantáneamente.
class RlCurrentSimulation extends ComponentSimulation {
  const RlCurrentSimulation();

  @override
  String get id => 'rl_current';

  @override
  String get title => 'Inductor: corriente en un circuito RL';

  @override
  String get circuit =>
      'Una fuente escalón alimenta un inductor en serie con un resistor.';

  @override
  String get learningGoal =>
      'Ver que el inductor se opone a los cambios de corriente y entender '
      'por qué al desconectarlo aparece una sobretensión.';

  @override
  String get assumptions =>
      'Inductor ideal sin resistencia de bobinado ni saturación del núcleo.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vs',
          label: 'Tensión de la fuente',
          unit: 'V',
          min: 1,
          max: 24,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'r',
          label: 'Resistencia',
          unit: 'Ω',
          min: 1,
          max: 1000,
          defaultValue: 10,
          logarithmic: true,
          decimals: 1,
        ),
        SimParameter(
          key: 'l',
          label: 'Inductancia',
          unit: 'mH',
          min: 0.1,
          max: 1000,
          defaultValue: 100,
          logarithmic: true,
          decimals: 1,
        ),
        SimParameter(
          key: 'tau',
          label: 'Instante observado',
          unit: 'τ',
          min: 0,
          max: 5,
          defaultValue: 1,
          decimals: 1,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Cuál es la corriente final? ¿Depende de L?',
        '¿Qué magnitud cambia si aumentas L: la corriente final o el tiempo?',
        '¿Por qué un relé necesita un diodo en antiparalelo?',
      ];

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vs = read(inputs, 'vs');
    final r = read(inputs, 'r');
    final l = read(inputs, 'l') * 1e-3;
    final k = read(inputs, 'tau');
    final tau = l / r;
    final iFinal = vs / r;
    final i = iFinal * (1 - math.exp(-k));
    final vl = vs * math.exp(-k);

    final messages = <SimMessage>[
      SimMessage(
        MessageLevel.info,
        'La tensión del inductor cae de ${vs.toStringAsFixed(1)} V a '
        '${vl.toStringAsFixed(2)} V mientras la corriente crece.',
      ),
      const SimMessage(
        MessageLevel.warning,
        'Si abres el circuito de golpe, el inductor genera una sobretensión '
        '(v = L·di/dt). Protege el interruptor con un diodo de rueda libre.',
      ),
    ];
    if (iFinal > 1) {
      messages.add(const SimMessage(
        MessageLevel.danger,
        'La corriente final supera 1 A: verifica la corriente de saturación '
        'del inductor y la potencia del resistor.',
      ));
    }

    final points = linspace(0, 5, 51)
        .map((x) => CurvePoint(x, iFinal * (1 - math.exp(-x)) * 1000))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'tau', label: 'Constante de tiempo τ', value: tau, unit: 's'),
        SimOutput(key: 'i', label: 'Corriente en el instante', value: i, unit: 'A'),
        SimOutput(key: 'ifinal', label: 'Corriente final', value: iFinal, unit: 'A'),
        SimOutput(key: 'vl', label: 'Tensión en el inductor', value: vl, unit: 'V'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Crecimiento de la corriente',
        xLabel: 'Tiempo (en τ)',
        yLabel: 'Corriente (mA)',
        points: points,
        marker: CurvePoint(k, i * 1000),
      ),
    );
  }
}
