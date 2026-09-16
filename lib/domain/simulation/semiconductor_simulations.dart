import 'dart:math' as math;

import 'simulation.dart';
import 'standard_values.dart';

/// Modelo de Shockley del diodo de silicio.
abstract final class DiodeModel {
  /// Corriente de saturación inversa (A).
  static const double saturationCurrent = 1e-14;

  /// Tensión térmica a 300 K (V).
  static const double thermalVoltage = 0.025852;

  static double current(double vd) =>
      saturationCurrent * (math.exp(vd / thermalVoltage) - 1);

  /// Resuelve el punto de operación de una fuente [vs] con resistor [r] en
  /// serie con el diodo, por bisección (siempre converge).
  static double operatingVoltage(double vs, double r) {
    if (vs <= 0) {
      // En inversa la corriente es prácticamente −Is: casi toda la tensión
      // queda en el diodo.
      return vs + saturationCurrent * r;
    }
    var lo = 0.0;
    var hi = vs;
    for (var k = 0; k < 200; k++) {
      final mid = (lo + hi) / 2;
      final f = (vs - mid) / r - current(mid);
      if (f > 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }
}

/// Diodo rectificador polarizado a través de un resistor.
class DiodeForwardSimulation extends ComponentSimulation {
  const DiodeForwardSimulation();

  @override
  String get id => 'diode_forward';

  @override
  String get title => 'Diodo: polarización directa e inversa';

  @override
  String get circuit =>
      'Una fuente ajustable alimenta un diodo de silicio a través de un '
      'resistor limitador.';

  @override
  String get learningGoal =>
      'Comprobar que el diodo conduce en un solo sentido y que, en directa, '
      'su tensión se mantiene cerca de 0.7 V aunque cambie la corriente.';

  @override
  String get assumptions =>
      'Ecuación de Shockley con Is = 10 fA, n = 1 y T = 300 K. Sin ruptura '
      'inversa.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vs',
          label: 'Tensión de la fuente',
          unit: 'V',
          min: -12,
          max: 12,
          defaultValue: 5,
          decimals: 1,
        ),
        SimParameter(
          key: 'r',
          label: 'Resistencia limitadora',
          unit: 'Ω',
          min: 100,
          max: 10000,
          defaultValue: 1000,
          logarithmic: true,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Invierte la fuente. ¿Cuánta corriente circula?',
        'Pasa de 5 V a 10 V. ¿Cuánto cambia la tensión del diodo?',
        '¿Qué error cometes si asumes 0.7 V fijos?',
      ];

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vs = read(inputs, 'vs');
    final r = read(inputs, 'r');
    final vd = DiodeModel.operatingVoltage(vs, r);
    final id = (vs - vd) / r;
    final pd = vd * id;
    final ideal = vs > 0.7 ? (vs - 0.7) / r : 0.0;

    final messages = <SimMessage>[];
    String state;
    if (vs <= 0) {
      state = 'Polarización inversa';
      messages.add(const SimMessage(
        MessageLevel.info,
        'Polarización inversa: el diodo bloquea y toda la tensión de la '
        'fuente queda sobre él. Verifica que no supere la tensión inversa '
        'máxima (1000 V en el 1N4007).',
      ));
    } else if (vd < 0.5) {
      state = 'Conducción débil';
      messages.add(const SimMessage(
        MessageLevel.info,
        'Por debajo del codo: la corriente es muy pequeña.',
      ));
    } else {
      state = 'Polarización directa';
      messages.add(SimMessage(
        MessageLevel.success,
        'Conduce. Con el modelo de 0.7 V la corriente sería '
        '${(ideal * 1000).toStringAsFixed(3)} mA.',
      ));
    }

    final points = linspace(0, 0.8, 41)
        .map((v) => CurvePoint(v, math.min(DiodeModel.current(v) * 1000, 50.0)))
        .toList();

    return SimResult(
      state: state,
      outputs: [
        SimOutput(key: 'vd', label: 'Tensión en el diodo', value: vd, unit: 'V'),
        SimOutput(key: 'id', label: 'Corriente', value: id, unit: 'A'),
        SimOutput(key: 'vr', label: 'Tensión en el resistor', value: vs - vd, unit: 'V'),
        SimOutput(key: 'pd', label: 'Potencia en el diodo', value: pd, unit: 'W'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Curva característica I–V',
        xLabel: 'Tensión del diodo (V)',
        yLabel: 'Corriente (mA)',
        points: points,
        marker: vs > 0 ? CurvePoint(vd, math.min(id * 1000, 50.0)) : null,
      ),
    );
  }
}

/// Regulador Zener con resistor serie y carga.
class ZenerRegulatorSimulation extends ComponentSimulation {
  const ZenerRegulatorSimulation();

  static const double vz = 5.1;
  static const double pzMax = 0.5;
  static const double izMin = 0.001;

  @override
  String get id => 'zener_regulator';

  @override
  String get title => 'Zener: regulador en paralelo';

  @override
  String get circuit =>
      'La fuente alimenta, a través de un resistor serie, un Zener de 5.1 V '
      'en paralelo con la carga.';

  @override
  String get learningGoal =>
      'Identificar las dos condiciones de diseño: corriente mínima para '
      'regular y potencia máxima del Zener.';

  @override
  String get assumptions =>
      'Zener ideal de 5.1 V y 0.5 W, corriente mínima de regulación 1 mA, '
      'resistencia dinámica nula.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vin',
          label: 'Tensión de entrada',
          unit: 'V',
          min: 5,
          max: 20,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'rs',
          label: 'Resistor serie',
          unit: 'Ω',
          min: 50,
          max: 2000,
          defaultValue: 220,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'rl',
          label: 'Resistencia de la carga',
          unit: 'Ω',
          min: 100,
          max: 10000,
          defaultValue: 1000,
          logarithmic: true,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Baja la carga a 100 Ω. ¿Sigue regulando?',
        'Sube la entrada a 20 V con Rs = 50 Ω. ¿Qué le pasa al Zener?',
        '¿Por qué el Zener no es buena opción para cargas de cientos de mA?',
      ];

  static double outputFor({
    required double vin,
    required double rs,
    required double rl,
  }) {
    final open = vin * rl / (rs + rl);
    return open < vz ? open : vz;
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vin = read(inputs, 'vin');
    final rs = read(inputs, 'rs');
    final rl = read(inputs, 'rl');
    final vout = outputFor(vin: vin, rs: rs, rl: rl);
    final regulating = vout >= vz;
    final iSeries = (vin - vout) / rs;
    final il = vout / rl;
    final iz = regulating ? iSeries - il : 0.0;
    final pz = vz * iz;
    final prs = (vin - vout) * iSeries;

    final messages = <SimMessage>[];
    String state;
    if (!regulating) {
      state = 'Sin regulación';
      messages.add(const SimMessage(
        MessageLevel.danger,
        'El Zener no conduce: la carga consume demasiado o la entrada es baja. '
        'La salida queda determinada por el divisor Rs–RL.',
      ));
    } else if (pz > pzMax) {
      state = 'Sobrecarga térmica';
      messages.add(const SimMessage(
        MessageLevel.danger,
        'El Zener disipa más de 0.5 W: se destruirá. Aumenta Rs.',
      ));
    } else if (iz < izMin) {
      state = 'Cerca del codo';
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Corriente de Zener menor a 1 mA: la regulación es pobre. Reduce Rs.',
      ));
    } else {
      state = 'Regulando';
      messages.add(const SimMessage(
        MessageLevel.success,
        'El Zener regula: la salida se mantiene en 5.1 V.',
      ));
    }

    final points = linspace(0, 20, 41)
        .map((x) => CurvePoint(x, outputFor(vin: x, rs: rs, rl: rl)))
        .toList();

    return SimResult(
      state: state,
      outputs: [
        SimOutput(key: 'vout', label: 'Tensión de salida', value: vout, unit: 'V'),
        SimOutput(key: 'is', label: 'Corriente en Rs', value: iSeries, unit: 'A'),
        SimOutput(key: 'il', label: 'Corriente en la carga', value: il, unit: 'A'),
        SimOutput(key: 'iz', label: 'Corriente en el Zener', value: iz, unit: 'A'),
        SimOutput(key: 'pz', label: 'Potencia en el Zener', value: pz, unit: 'W'),
        SimOutput(key: 'prs', label: 'Potencia en Rs', value: prs, unit: 'W'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida según la entrada',
        xLabel: 'Entrada (V)',
        yLabel: 'Salida (V)',
        points: points,
        marker: CurvePoint(vin, vout),
      ),
    );
  }
}

/// Cálculo del resistor limitador de un LED.
class LedResistorSimulation extends ComponentSimulation {
  const LedResistorSimulation();

  static const List<String> colors = [
    'Rojo',
    'Amarillo',
    'Verde',
    'Azul',
    'Blanco',
  ];

  /// Tensión directa típica por color (V).
  static const List<double> forwardVoltages = [2.0, 2.1, 3.0, 3.2, 3.2];

  @override
  String get id => 'led_resistor';

  @override
  String get title => 'LED: resistor limitador';

  @override
  String get circuit =>
      'Una fuente alimenta un LED en serie con un resistor limitador.';

  @override
  String get learningGoal =>
      'Calcular el resistor limitador, elegir el valor comercial y verificar '
      'la corriente real y la potencia.';

  @override
  String get assumptions =>
      'Tensión directa constante según el color (valores típicos); resistor '
      'redondeado al valor E12 superior.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vcc',
          label: 'Tensión de alimentación',
          unit: 'V',
          min: 3,
          max: 24,
          defaultValue: 5,
          decimals: 1,
        ),
        SimParameter(
          key: 'color',
          label: 'Color del LED',
          unit: '',
          min: 0,
          max: 4,
          defaultValue: 0,
          decimals: 0,
          optionLabels: colors,
        ),
        SimParameter(
          key: 'if',
          label: 'Corriente deseada',
          unit: 'mA',
          min: 1,
          max: 30,
          defaultValue: 15,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Por qué un LED azul no enciende bien con 3.3 V?',
        '¿Por qué se elige el valor comercial superior y no el inferior?',
        '¿Qué potencia debe tener el resistor con 24 V y 20 mA?',
      ];

  static double calculatedResistance({
    required double vcc,
    required double vf,
    required double current,
  }) =>
      (vcc - vf) / current;

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vcc = read(inputs, 'vcc');
    final colorIndex = read(inputs, 'color').round().clamp(0, 4).toInt();
    final vf = forwardVoltages[colorIndex];
    final iTarget = read(inputs, 'if') / 1000;

    if (vcc <= vf) {
      return SimResult(
        state: 'LED apagado',
        outputs: [
          SimOutput(key: 'vf', label: 'Tensión directa del LED', value: vf, unit: 'V'),
        ],
        messages: const [
          SimMessage(
            MessageLevel.danger,
            'La alimentación no supera la tensión directa del LED: no '
            'encenderá. Usa una fuente mayor o un LED de menor tensión directa.',
          ),
        ],
      );
    }

    final rCalc = calculatedResistance(vcc: vcc, vf: vf, current: iTarget);
    final rStd = nextE12(rCalc);
    final iReal = (vcc - vf) / rStd;
    final pR = iReal * iReal * rStd;

    final messages = <SimMessage>[];
    if (iTarget > 0.02) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Más de 20 mA: supera la corriente continua típica de un LED de 5 mm '
        'y acorta su vida útil.',
      ));
    }
    if (pR > 0.125) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'El resistor disipa más de 1/8 W: usa uno de 1/2 W para mantener '
        'margen térmico.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Un resistor de 1/4 W es suficiente.',
      ));
    }

    return SimResult(
      state: 'LED encendido',
      outputs: [
        SimOutput(key: 'vf', label: 'Tensión directa del LED', value: vf, unit: 'V'),
        SimOutput(key: 'r_calc', label: 'Resistencia calculada', value: rCalc, unit: 'Ω'),
        SimOutput(key: 'r_std', label: 'Valor comercial E12', value: rStd, unit: 'Ω'),
        SimOutput(key: 'i_real', label: 'Corriente real', value: iReal, unit: 'A'),
        SimOutput(key: 'p_r', label: 'Potencia en el resistor', value: pR, unit: 'W'),
      ],
      messages: messages,
    );
  }
}

/// Transistor NPN como interruptor (modelo por regiones).
class BjtSwitchSimulation extends ComponentSimulation {
  const BjtSwitchSimulation();

  static const double vbe = 0.7;
  static const double vceSat = 0.2;
  static const double maxCollectorCurrent = 0.6;
  static const double maxPower = 0.5;

  @override
  String get id => 'bjt_switch';

  @override
  String get title => 'Transistor NPN como interruptor';

  @override
  String get circuit =>
      'Una señal de control llega a la base por un resistor; la carga Rc va '
      'del colector a la alimentación y el emisor a tierra.';

  @override
  String get learningGoal =>
      'Distinguir corte, zona activa y saturación, y dimensionar Rb para que '
      'el transistor sature como interruptor.';

  @override
  String get assumptions =>
      'Modelo por regiones: VBE = 0.7 V, VCE(sat) = 0.2 V, β constante. '
      'Límites de referencia del 2N2222: 600 mA y 0.5 W.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vin',
          label: 'Tensión de control',
          unit: 'V',
          min: 0,
          max: 5,
          defaultValue: 5,
          decimals: 2,
        ),
        SimParameter(
          key: 'rb',
          label: 'Resistor de base',
          unit: 'Ω',
          min: 1000,
          max: 1000000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'rc',
          label: 'Carga en el colector',
          unit: 'Ω',
          min: 10,
          max: 10000,
          defaultValue: 1000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'vcc',
          label: 'Alimentación de la carga',
          unit: 'V',
          min: 5,
          max: 24,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'beta',
          label: 'Ganancia β',
          unit: '',
          min: 50,
          max: 300,
          defaultValue: 100,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Sube Rb a 1 MΩ. ¿En qué región queda el transistor?',
        '¿Qué pasa con la potencia del transistor en la zona activa?',
        'Con Rc = 10 Ω y 12 V, ¿el 2N2222 soporta la corriente?',
      ];

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vin = read(inputs, 'vin');
    final rb = read(inputs, 'rb');
    final rc = read(inputs, 'rc');
    final vcc = read(inputs, 'vcc');
    final beta = read(inputs, 'beta');
    return solve(vin: vin, rb: rb, rc: rc, vcc: vcc, beta: beta);
  }

  static double collectorCurrent({
    required double vin,
    required double rb,
    required double rc,
    required double vcc,
    required double beta,
  }) {
    if (vin <= vbe) return 0;
    final ib = (vin - vbe) / rb;
    final icSat = (vcc - vceSat) / rc;
    return math.min(beta * ib, icSat);
  }

  SimResult solve({
    required double vin,
    required double rb,
    required double rc,
    required double vcc,
    required double beta,
  }) {
    final messages = <SimMessage>[];
    String state;
    double ib;
    double ic;
    double vce;

    if (vin <= vbe) {
      state = 'Corte';
      ib = 0;
      ic = 0;
      vce = vcc;
      messages.add(const SimMessage(
        MessageLevel.info,
        'Corte: la tensión de control no supera 0.7 V. El interruptor está '
        'abierto y la carga, apagada.',
      ));
    } else {
      ib = (vin - vbe) / rb;
      final icActive = beta * ib;
      final icSat = (vcc - vceSat) / rc;
      if (icActive >= icSat) {
        state = 'Saturación';
        ic = icSat;
        vce = vceSat;
        final overdrive = icActive / icSat;
        if (overdrive < 2) {
          messages.add(const SimMessage(
            MessageLevel.warning,
            'Satura con poco margen: si β baja por temperatura o por '
            'dispersión, saldrá de saturación. Busca una corriente de base '
            'al menos el doble de la mínima.',
          ));
        } else {
          messages.add(const SimMessage(
            MessageLevel.success,
            'Saturación con margen: funciona como interruptor cerrado.',
          ));
        }
      } else {
        state = 'Zona activa';
        ic = icActive;
        vce = vcc - ic * rc;
        messages.add(const SimMessage(
          MessageLevel.warning,
          'Zona activa: el transistor amplifica, no conmuta. Disipa más '
          'potencia y la carga no recibe toda la tensión. Reduce Rb.',
        ));
      }
    }

    final p = vce * ic;
    if (ic > maxCollectorCurrent) {
      messages.add(const SimMessage(
        MessageLevel.danger,
        'La corriente de colector supera 600 mA: el 2N2222 no es adecuado. '
        'Usa un MOSFET o un transistor de potencia.',
      ));
    }
    if (p > maxPower) {
      messages.add(const SimMessage(
        MessageLevel.danger,
        'El transistor disipa más de 0.5 W: se sobrecalentará.',
      ));
    }

    final points = linspace(0, 5, 51)
        .map((x) => CurvePoint(
              x,
              collectorCurrent(vin: x, rb: rb, rc: rc, vcc: vcc, beta: beta) *
                  1000,
            ))
        .toList();

    return SimResult(
      state: state,
      outputs: [
        SimOutput(key: 'ib', label: 'Corriente de base', value: ib, unit: 'A'),
        SimOutput(key: 'ic', label: 'Corriente de colector', value: ic, unit: 'A'),
        SimOutput(key: 'vce', label: 'Tensión colector-emisor', value: vce, unit: 'V'),
        SimOutput(key: 'p', label: 'Potencia en el transistor', value: p, unit: 'W'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Corriente de colector según el control',
        xLabel: 'Tensión de control (V)',
        yLabel: 'Corriente de colector (mA)',
        points: points,
        marker: CurvePoint(vin, ic * 1000),
      ),
    );
  }
}

/// MOSFET de canal N como interruptor de una carga.
class MosfetSwitchSimulation extends ComponentSimulation {
  const MosfetSwitchSimulation();

  /// Parámetro de transconductancia del modelo cuadrático (A/V²).
  static const double k = 1.0;

  /// Resistencia de encendido especificada con VGS = 10 V (Ω).
  static const double rdsOnAt10V = 0.05;

  @override
  String get id => 'mosfet_switch';

  @override
  String get title => 'MOSFET de canal N como interruptor';

  @override
  String get circuit =>
      'La compuerta recibe la tensión de control; la carga RL va de la '
      'alimentación al drenador y la fuente a tierra.';

  @override
  String get learningGoal =>
      'Entender que la tensión de umbral no es la tensión para conducir '
      'plenamente y por qué existen los MOSFET de nivel lógico.';

  @override
  String get assumptions =>
      'Modelo cuadrático con k = 1 A/V²; RDS(on) = 50 mΩ con VGS = 10 V, '
      'escalado de forma inversa con la sobretensión de compuerta.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'vgs',
          label: 'Tensión de compuerta',
          unit: 'V',
          min: 0,
          max: 10,
          defaultValue: 3.3,
          decimals: 1,
        ),
        SimParameter(
          key: 'vth',
          label: 'Tensión de umbral',
          unit: 'V',
          min: 1,
          max: 4,
          defaultValue: 2,
          decimals: 1,
        ),
        SimParameter(
          key: 'vdd',
          label: 'Alimentación de la carga',
          unit: 'V',
          min: 5,
          max: 24,
          defaultValue: 12,
          decimals: 1,
        ),
        SimParameter(
          key: 'rl',
          label: 'Resistencia de la carga',
          unit: 'Ω',
          min: 1,
          max: 1000,
          defaultValue: 12,
          logarithmic: true,
          decimals: 1,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        'Con Vth = 2 V, ¿basta 3.3 V para encender por completo una carga de 1 A?',
        '¿Cuánta potencia disipa el MOSFET en cada región?',
        '¿Por qué la compuerta casi no consume corriente?',
      ];

  static double rdsOn(double vgs, double vth) =>
      rdsOnAt10V * (10 - vth) / (vgs - vth);

  static double drainCurrent({
    required double vgs,
    required double vth,
    required double vdd,
    required double rl,
  }) {
    if (vgs <= vth) return 0;
    final iSat = k / 2 * (vgs - vth) * (vgs - vth);
    final iOhmic = vdd / (rl + rdsOn(vgs, vth));
    return math.min(iSat, iOhmic);
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final vgs = read(inputs, 'vgs');
    final vth = read(inputs, 'vth');
    final vdd = read(inputs, 'vdd');
    final rl = read(inputs, 'rl');

    final messages = <SimMessage>[];
    String state;
    double id;
    double vds;

    if (vgs <= vth) {
      state = 'Corte';
      id = 0;
      vds = vdd;
      messages.add(const SimMessage(
        MessageLevel.info,
        'Corte: la compuerta no supera la tensión de umbral. La carga está '
        'apagada.',
      ));
    } else {
      final iSat = k / 2 * (vgs - vth) * (vgs - vth);
      final rds = rdsOn(vgs, vth);
      final iOhmic = vdd / (rl + rds);
      if (iSat < iOhmic) {
        state = 'Saturación (conducción parcial)';
        id = iSat;
        vds = vdd - id * rl;
        messages.add(const SimMessage(
          MessageLevel.danger,
          'Conduce parcialmente: el MOSFET limita la corriente y disipa mucha '
          'potencia. Eleva la tensión de compuerta o usa un MOSFET de nivel '
          'lógico.',
        ));
      } else {
        state = 'Óhmica (encendido pleno)';
        id = iOhmic;
        vds = id * rds;
        messages.add(const SimMessage(
          MessageLevel.success,
          'Encendido pleno: se comporta como una resistencia muy pequeña.',
        ));
      }
    }
    final p = vds * id;
    if (p > 1) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Disipa más de 1 W: en encapsulado TO-220 necesitará disipador.',
      ));
    }

    final points = linspace(0, 10, 51)
        .map((x) => CurvePoint(
              x,
              drainCurrent(vgs: x, vth: vth, vdd: vdd, rl: rl),
            ))
        .toList();

    return SimResult(
      state: state,
      outputs: [
        SimOutput(key: 'id', label: 'Corriente de drenador', value: id, unit: 'A'),
        SimOutput(key: 'vds', label: 'Tensión drenador-fuente', value: vds, unit: 'V'),
        SimOutput(key: 'vload', label: 'Tensión en la carga', value: id * rl, unit: 'V'),
        SimOutput(key: 'p', label: 'Potencia en el MOSFET', value: p, unit: 'W'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Corriente según la tensión de compuerta',
        xLabel: 'VGS (V)',
        yLabel: 'Corriente (A)',
        points: points,
        marker: CurvePoint(vgs, id),
      ),
    );
  }
}
