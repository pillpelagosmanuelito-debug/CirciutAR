import 'learning_module.dart';

/// Tipo de símbolo esquemático que dibuja la aplicación.
enum SymbolType {
  resistor,
  potentiometer,
  capacitorCeramic,
  capacitorElectrolytic,
  inductor,
  diode,
  zener,
  led,
  bjtNpn,
  mosfetN,
  opAmp,
  regulator,
  timer555,
  ldr,
  ntc,
  tempSensorIc,
  ultrasonic,
}

/// Descripción del símbolo, útil para la galería y la retroalimentación.
extension SymbolTypeInfo on SymbolType {
  String get description => switch (this) {
        SymbolType.resistor =>
          'Resistor: línea en zigzag (norma ANSI) o rectángulo (norma IEC).',
        SymbolType.potentiometer =>
          'Potenciómetro: resistor con una flecha que toca su cuerpo (cursor).',
        SymbolType.capacitorCeramic =>
          'Capacitor no polarizado: dos placas paralelas rectas.',
        SymbolType.capacitorElectrolytic =>
          'Capacitor polarizado: una placa curva y el signo + en la otra.',
        SymbolType.inductor =>
          'Inductor: una serie de espiras o semicírculos.',
        SymbolType.diode =>
          'Diodo: triángulo que apunta a una barra recta (cátodo).',
        SymbolType.zener =>
          'Zener: como el diodo, pero la barra del cátodo tiene los extremos doblados.',
        SymbolType.led =>
          'LED: símbolo de diodo con dos flechas que salen (luz emitida).',
        SymbolType.bjtNpn =>
          'Transistor NPN: base unida a una barra; la flecha del emisor apunta hacia afuera.',
        SymbolType.mosfetN =>
          'MOSFET de canal N: la compuerta no toca el canal; la flecha apunta hacia el canal.',
        SymbolType.opAmp =>
          'Amplificador operacional: triángulo con entradas + y − y una salida.',
        SymbolType.regulator =>
          'Regulador: bloque con entrada (IN), tierra (GND) y salida (OUT).',
        SymbolType.timer555 =>
          'Temporizador 555: bloque rectangular de ocho pines numerados.',
        SymbolType.ldr =>
          'LDR: resistor con flechas que llegan desde afuera (luz recibida).',
        SymbolType.ntc =>
          'NTC: resistor atravesado por una línea diagonal con la marca −t°.',
        SymbolType.tempSensorIc =>
          'Sensor integrado: bloque de tres terminales (+Vs, Vout y GND).',
        SymbolType.ultrasonic =>
          'Módulo ultrasónico: emisor (T) y receptor (R) con ondas.',
      };
}

/// Parámetro técnico que aparece en una hoja de datos.
class Characteristic {
  const Characteristic({
    required this.name,
    required this.value,
    this.note,
  });

  final String name;
  final String value;

  /// Explicación breve de por qué el parámetro importa al seleccionar.
  final String? note;
}

/// Error frecuente de estudiantes, con su consecuencia y su corrección.
class CommonMistake {
  const CommonMistake({
    required this.mistake,
    required this.consequence,
    required this.correction,
  });

  final String mistake;
  final String consequence;
  final String correction;
}

/// Claves estándar para comparar componentes de forma genérica.
abstract final class TraitKeys {
  static const function = 'Función principal';
  static const polarity = 'Polaridad';
  static const keyMagnitude = 'Magnitud característica';
  static const typicalRange = 'Rango típico';
  static const response = 'Comportamiento clave';
  static const cost = 'Costo relativo';

  static const all = <String>[
    function,
    polarity,
    keyMagnitude,
    typicalRange,
    response,
    cost,
  ];
}

/// Ficha completa de un componente electrónico.
class ElectronicComponent {
  const ElectronicComponent({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.symbol,
    required this.summary,
    required this.howItWorks,
    required this.keyFormula,
    required this.characteristics,
    required this.applications,
    required this.useWhen,
    required this.avoidWhen,
    required this.mistakes,
    required this.identificationTips,
    required this.packages,
    required this.traits,
    this.simulationId,
    this.example,
  });

  final String id;
  final String name;
  final String shortName;
  final ComponentCategory category;
  final SymbolType symbol;

  /// Una línea: qué es y para qué sirve.
  final String summary;

  /// Funcionamiento explicado con lenguaje de curso.
  final String howItWorks;

  /// Relación matemática central, en texto legible.
  final String keyFormula;

  final List<Characteristic> characteristics;
  final List<String> applications;

  /// Criterios de selección: cuándo conviene usarlo.
  final List<String> useWhen;

  /// Criterios de selección: cuándo no conviene y qué usar en su lugar.
  final List<String> avoidWhen;

  final List<CommonMistake> mistakes;

  /// Cómo reconocerlo físicamente en una placa o protoboard.
  final List<String> identificationTips;

  final List<String> packages;

  /// Rasgos comparables; las claves provienen de [TraitKeys].
  final Map<String, String> traits;

  /// Simulación asociada en el laboratorio.
  final String? simulationId;

  /// Ejemplo comercial de referencia (por ejemplo, 1N4007).
  final String? example;
}
