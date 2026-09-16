import 'dart:math' as math;

import 'simulation.dart';

/// Fotorresistencia (LDR) en un divisor de tensión.
class LdrDividerSimulation extends ComponentSimulation {
  const LdrDividerSimulation();

  /// Resistencia a 10 lux (Ω) y exponente de la curva (modelo potencial).
  static const double r10 = 10000;
  static const double gamma = 0.7;

  @override
  String get id => 'ldr_divider';

  @override
  String get title => 'LDR en divisor de tensión';

  @override
  String get circuit =>
      'La LDR va de la alimentación a la salida y un resistor fijo, de la '
      'salida a tierra. Más luz produce más tensión.';

  @override
  String get learningGoal =>
      'Convertir un cambio de resistencia en un cambio de tensión medible y '
      'elegir el resistor fijo para máxima sensibilidad.';

  @override
  String get assumptions =>
      'R = 10 kΩ · (E / 10 lx)^−0.7, valores típicos de una GL5528. Se ignora '
      'el tiempo de respuesta.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'lux',
          label: 'Iluminancia',
          unit: 'lx',
          min: 1,
          max: 10000,
          defaultValue: 100,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'rf',
          label: 'Resistor fijo',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
        SimParameter(
          key: 'vcc',
          label: 'Alimentación',
          unit: 'V',
          min: 3.3,
          max: 5,
          defaultValue: 5,
          decimals: 1,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Cuánto vale la LDR en penumbra (10 lx) y a pleno sol?',
        'Si quieres detectar el anochecer, ¿qué resistor fijo elegirías?',
        '¿Sirve una LDR para medir lux con precisión? ¿Por qué?',
      ];

  static double resistance(double lux) => r10 * math.pow(lux / 10, -gamma);

  static double output({
    required double lux,
    required double rf,
    required double vcc,
  }) {
    final r = resistance(lux);
    return vcc * rf / (r + rf);
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final lux = read(inputs, 'lux');
    final rf = read(inputs, 'rf');
    final vcc = read(inputs, 'vcc');
    final r = resistance(lux);
    final vout = output(lux: lux, rf: rf, vcc: vcc);

    final messages = <SimMessage>[
      const SimMessage(
        MessageLevel.info,
        'La sensibilidad es máxima cuando el resistor fijo se parece a la '
        'resistencia de la LDR en el nivel de luz que quieres detectar.',
      ),
      const SimMessage(
        MessageLevel.warning,
        'La LDR es lenta (decenas de milisegundos) y poco precisa: sirve para '
        'detectar umbrales, no para medir lux.',
      ),
    ];

    final points = linspace(0, 4, 41)
        .map((e) => CurvePoint(
              e,
              output(lux: math.pow(10, e).toDouble(), rf: rf, vcc: vcc),
            ))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'rldr', label: 'Resistencia de la LDR', value: r, unit: 'Ω'),
        SimOutput(key: 'vout', label: 'Tensión de salida', value: vout, unit: 'V'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida según la luz',
        xLabel: 'log₁₀ de la iluminancia (lx)',
        yLabel: 'Salida (V)',
        points: points,
        marker: CurvePoint(math.log(lux) / math.ln10, vout),
      ),
    );
  }
}

/// Termistor NTC en un divisor de tensión (modelo Beta).
class NtcDividerSimulation extends ComponentSimulation {
  const NtcDividerSimulation();

  static const double r25 = 10000;
  static const double t25 = 298.15;

  @override
  String get id => 'ntc_divider';

  @override
  String get title => 'Termistor NTC en divisor';

  @override
  String get circuit =>
      'La NTC va de la alimentación a la salida y un resistor fijo, de la '
      'salida a tierra. Más temperatura produce más tensión.';

  @override
  String get learningGoal =>
      'Observar la respuesta no lineal del termistor y el efecto del '
      'coeficiente Beta.';

  @override
  String get assumptions =>
      'R(T) = R25 · e^(B·(1/T − 1/298.15)) con R25 = 10 kΩ. Sin '
      'autocalentamiento.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 't',
          label: 'Temperatura',
          unit: '°C',
          min: -20,
          max: 100,
          defaultValue: 25,
          decimals: 0,
        ),
        SimParameter(
          key: 'beta',
          label: 'Coeficiente Beta',
          unit: 'K',
          min: 3000,
          max: 4500,
          defaultValue: 3950,
          decimals: 0,
        ),
        SimParameter(
          key: 'rf',
          label: 'Resistor fijo',
          unit: 'Ω',
          min: 1000,
          max: 100000,
          defaultValue: 10000,
          logarithmic: true,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿La tensión cambia lo mismo entre 0 y 10 °C que entre 80 y 90 °C?',
        '¿Por qué hace falta una tabla o una ecuación para convertir la lectura?',
        '¿Qué ventaja tiene la NTC frente al LM35?',
      ];

  static double resistance(double celsius, double beta) {
    final tk = celsius + 273.15;
    return r25 * math.exp(beta * (1 / tk - 1 / t25));
  }

  static double output({
    required double celsius,
    required double beta,
    required double rf,
    double vcc = 5,
  }) {
    final r = resistance(celsius, beta);
    return vcc * rf / (r + rf);
  }

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final t = read(inputs, 't');
    final beta = read(inputs, 'beta');
    final rf = read(inputs, 'rf');
    final r = resistance(t, beta);
    final vout = output(celsius: t, beta: beta, rf: rf);
    final slopeLow = (output(celsius: 10, beta: beta, rf: rf) -
            output(celsius: 0, beta: beta, rf: rf)) /
        10;
    final slopeHigh = (output(celsius: 90, beta: beta, rf: rf) -
            output(celsius: 80, beta: beta, rf: rf)) /
        10;

    final messages = <SimMessage>[
      SimMessage(
        MessageLevel.info,
        'Sensibilidad: ${(slopeLow * 1000).toStringAsFixed(1)} mV/°C entre 0 y '
        '10 °C, y ${(slopeHigh * 1000).toStringAsFixed(1)} mV/°C entre 80 y '
        '90 °C. La respuesta no es lineal.',
      ),
      const SimMessage(
        MessageLevel.warning,
        'Si circula mucha corriente, la NTC se calienta sola y mide de más. '
        'Usa resistores de valor alto.',
      ),
    ];

    final points = linspace(-20, 100, 49)
        .map((x) => CurvePoint(x, output(celsius: x, beta: beta, rf: rf)))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'rntc', label: 'Resistencia de la NTC', value: r, unit: 'Ω'),
        SimOutput(key: 'vout', label: 'Tensión de salida (Vcc = 5 V)', value: vout, unit: 'V'),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida según la temperatura',
        xLabel: 'Temperatura (°C)',
        yLabel: 'Salida (V)',
        points: points,
        marker: CurvePoint(t, vout),
      ),
    );
  }
}

/// Sensor integrado LM35 leído por un conversor analógico-digital.
class Lm35Simulation extends ComponentSimulation {
  const Lm35Simulation();

  static const double sensitivity = 0.010;

  @override
  String get id => 'lm35_adc';

  @override
  String get title => 'LM35 y conversor analógico-digital';

  @override
  String get circuit =>
      'La salida del LM35 entra a un ADC de 10 bits de un microcontrolador.';

  @override
  String get learningGoal =>
      'Usar la relación lineal de 10 mV/°C y calcular la resolución real de '
      'la medición.';

  @override
  String get assumptions =>
      'Configuración básica (fuente simple): mide de 2 a 150 °C. ADC ideal '
      'de 10 bits.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 't',
          label: 'Temperatura',
          unit: '°C',
          min: 0,
          max: 150,
          defaultValue: 25,
          decimals: 0,
        ),
        SimParameter(
          key: 'vref',
          label: 'Referencia del ADC',
          unit: '',
          min: 0,
          max: 1,
          defaultValue: 0,
          decimals: 0,
          optionLabels: ['5 V', '3.3 V'],
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Qué tensión entrega a 37 °C?',
        '¿Cuántos grados representa cada paso del ADC con referencia de 5 V?',
        '¿Cómo mejorarías la resolución sin cambiar de microcontrolador?',
      ];

  static double outputVoltage(double celsius) => sensitivity * celsius;

  static int adcCode(double volts, double vref) =>
      (volts / vref * 1023).round().clamp(0, 1023).toInt();

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final t = read(inputs, 't');
    final vref = read(inputs, 'vref') < 0.5 ? 5.0 : 3.3;
    final vout = outputVoltage(t);
    final code = adcCode(vout, vref);
    final resolution = vref / 1023 / sensitivity;
    final measured = code * vref / 1023 / sensitivity;

    final messages = <SimMessage>[
      SimMessage(
        MessageLevel.info,
        'Cada paso del ADC equivale a ${resolution.toStringAsFixed(2)} °C. '
        'Amplificar la señal (por ejemplo, ×3) mejora la resolución.',
      ),
    ];
    if (t < 2) {
      messages.add(const SimMessage(
        MessageLevel.warning,
        'Por debajo de 2 °C la configuración básica no funciona: se necesita '
        'una fuente negativa y un resistor de polarización.',
      ));
    }

    final points = linspace(0, 150, 31)
        .map((x) => CurvePoint(x, outputVoltage(x) * 1000))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'vout', label: 'Tensión de salida', value: vout, unit: 'V'),
        SimOutput(
          key: 'code',
          label: 'Código del ADC',
          value: code.toDouble(),
          unit: '',
          plain: true,
        ),
        SimOutput(
          key: 'measured',
          label: 'Temperatura reconstruida',
          value: measured,
          unit: '°C',
          plain: true,
        ),
        SimOutput(
          key: 'resolution',
          label: 'Resolución',
          value: resolution,
          unit: '°C',
          plain: true,
        ),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Salida del LM35',
        xLabel: 'Temperatura (°C)',
        yLabel: 'Salida (mV)',
        points: points,
        marker: CurvePoint(t, vout * 1000),
      ),
    );
  }
}

/// Sensor ultrasónico HC-SR04: tiempo de vuelo.
class UltrasonicSimulation extends ComponentSimulation {
  const UltrasonicSimulation();

  static double soundSpeed(double celsius) => 331.3 + 0.606 * celsius;

  @override
  String get id => 'ultrasonic_tof';

  @override
  String get title => 'Sensor ultrasónico: tiempo de vuelo';

  @override
  String get circuit =>
      'El HC-SR04 emite un pulso de 40 kHz y entrega un pulso de eco cuya '
      'duración es el tiempo de ida y vuelta.';

  @override
  String get learningGoal =>
      'Relacionar la duración del eco con la distancia y ver el efecto de la '
      'temperatura en la velocidad del sonido.';

  @override
  String get assumptions =>
      'c = 331.3 + 0.606·T m/s. El microcontrolador asume 343 m/s (20 °C). '
      'Rango útil de 2 a 400 cm.';

  @override
  List<SimParameter> get parameters => const [
        SimParameter(
          key: 'd',
          label: 'Distancia real',
          unit: 'cm',
          min: 2,
          max: 400,
          defaultValue: 100,
          decimals: 0,
        ),
        SimParameter(
          key: 't',
          label: 'Temperatura del aire',
          unit: '°C',
          min: 0,
          max: 40,
          defaultValue: 20,
          decimals: 0,
        ),
      ];

  @override
  List<String> get guidingQuestions => const [
        '¿Por qué se divide entre dos el tiempo del eco?',
        'A 35 °C, ¿el sensor mide de más o de menos?',
        '¿Qué superficies podrían no devolver el eco?',
      ];

  static double echoTime({required double meters, required double celsius}) =>
      2 * meters / soundSpeed(celsius);

  @override
  SimResult evaluate(Map<String, double> inputs) {
    final dCm = read(inputs, 'd');
    final t = read(inputs, 't');
    final c = soundSpeed(t);
    final echo = echoTime(meters: dCm / 100, celsius: t);
    final estimatedCm = echo * 343 / 2 * 100;
    final error = estimatedCm - dCm;

    final messages = <SimMessage>[];
    if (error.abs() > 1) {
      messages.add(SimMessage(
        MessageLevel.warning,
        'Asumir 343 m/s produce un error de ${error.toStringAsFixed(1)} cm. '
        'Compensa con un sensor de temperatura si necesitas precisión.',
      ));
    } else {
      messages.add(const SimMessage(
        MessageLevel.success,
        'Error por temperatura menor a 1 cm.',
      ));
    }
    messages.add(const SimMessage(
      MessageLevel.info,
      'Superficies blandas o inclinadas absorben o desvían el eco y producen '
      'lecturas falsas.',
    ));

    final points = linspace(2, 400, 41)
        .map((x) => CurvePoint(x, echoTime(meters: x / 100, celsius: t) * 1000))
        .toList();

    return SimResult(
      outputs: [
        SimOutput(key: 'c', label: 'Velocidad del sonido', value: c, unit: 'm/s', plain: true),
        SimOutput(key: 'echo', label: 'Duración del eco', value: echo, unit: 's'),
        SimOutput(
          key: 'estimated',
          label: 'Distancia calculada (343 m/s)',
          value: estimatedCm,
          unit: 'cm',
          plain: true,
        ),
        SimOutput(key: 'error', label: 'Error', value: error, unit: 'cm', plain: true),
      ],
      messages: messages,
      curve: SimCurve(
        title: 'Duración del eco según la distancia',
        xLabel: 'Distancia (cm)',
        yLabel: 'Eco (ms)',
        points: points,
        marker: CurvePoint(dCm, echo * 1000),
      ),
    );
  }
}
