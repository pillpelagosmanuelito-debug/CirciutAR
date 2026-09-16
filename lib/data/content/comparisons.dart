import '../../domain/models/comparison.dart';

/// Comparaciones curadas entre pares que los estudiantes suelen confundir.
const List<CuratedComparison> curatedComparisons = [
  CuratedComparison(
    aId: 'capacitor_ceramic',
    bId: 'capacitor_electrolytic',
    keyDifference:
        'El cerámico es pequeño, rápido y sin polaridad; el electrolítico '
        'ofrece mucha capacidad a baja frecuencia pero es polarizado.',
    chooseAWhen: 'Desacoplar integrados y filtrar ruido de alta frecuencia.',
    chooseBWhen: 'Filtrar el rizado de una fuente o almacenar energía.',
    rows: [
      ComparisonRow('Capacidad típica', 'pF a pocos µF', 'µF a miles de µF'),
      ComparisonRow('Polaridad', 'No', 'Sí: invertirlo lo destruye'),
      ComparisonRow('Alta frecuencia', 'Excelente', 'Pobre (ESR e inductancia)'),
      ComparisonRow('Vida útil', 'Muy larga', 'Limitada por el electrolito'),
      ComparisonRow('Uso combinado', '100 nF junto al integrado', 'Gran capacidad a la entrada'),
    ],
  ),
  CuratedComparison(
    aId: 'diode_rectifier',
    bId: 'diode_zener',
    keyDifference:
        'El rectificador se usa en directa para dejar pasar corriente; el '
        'Zener se usa en inversa para fijar una tensión.',
    chooseAWhen: 'Rectificar, proteger contra inversión de polaridad o como rueda libre.',
    chooseBWhen: 'Obtener una referencia de tensión o recortar sobretensiones.',
    rows: [
      ComparisonRow('Zona de trabajo', 'Polarización directa', 'Ruptura inversa'),
      ComparisonRow('Parámetro clave', 'IF y VRRM', 'Vz y Pz'),
      ComparisonRow('Tensión inversa', 'Hasta 1000 V sin conducir', 'Conduce a partir de Vz'),
      ComparisonRow('Resistor serie', 'Según el circuito', 'Obligatorio'),
    ],
  ),
  CuratedComparison(
    aId: 'bjt_npn',
    bId: 'mosfet_n',
    keyDifference:
        'El BJT se controla con corriente de base; el MOSFET, con tensión de '
        'compuerta y casi sin consumo.',
    chooseAWhen: 'Cargas pequeñas, amplificación de señal y mínimo costo.',
    chooseBWhen: 'Cargas de más de 0.5 A, PWM y baja disipación.',
    rows: [
      ComparisonRow('Control', 'Corriente de base', 'Tensión de compuerta'),
      ComparisonRow('Pérdidas encendido', 'VCE(sat) · IC', 'ID² · RDS(on)'),
      ComparisonRow('Corriente típica', 'Hasta ≈ 1 A (señal)', 'Decenas de A'),
      ComparisonRow('Riesgo común', 'No saturar por β bajo', 'VGS insuficiente'),
      ComparisonRow('Con 3.3 V de control', 'Funciona con RB adecuado', 'Solo si es de nivel lógico'),
    ],
  ),
  CuratedComparison(
    aId: 'ntc',
    bId: 'lm35',
    keyDifference:
        'La NTC es barata y muy sensible pero no lineal; el LM35 es lineal y '
        'calibrado pero necesita alimentación de al menos 4 V.',
    chooseAWhen: 'Bajo costo, rangos negativos o sistemas de 3.3 V con calibración.',
    chooseBWhen: 'Lectura directa en °C sin tablas ni calibración.',
    rows: [
      ComparisonRow('Tipo', 'Resistivo pasivo', 'Integrado activo'),
      ComparisonRow('Salida', 'Resistencia (requiere divisor)', 'Tensión: 10 mV/°C'),
      ComparisonRow('Linealidad', 'Exponencial', 'Lineal'),
      ComparisonRow('Rango típico', '−40 °C a 125 °C', '2 °C a 150 °C (básico)'),
      ComparisonRow('Conversión', 'Ecuación Beta o tabla', 'T = Vout / 0.01'),
    ],
  ),
  CuratedComparison(
    aId: 'diode_zener',
    bId: 'regulator_7805',
    keyDifference:
        'Ambos entregan una tensión fija, pero el Zener solo sirve para '
        'cargas pequeñas y el regulador maneja hasta 1.5 A.',
    chooseAWhen: 'Referencias o cargas de pocos mA y costo mínimo.',
    chooseBWhen: 'Alimentar circuitos que consumen decenas o cientos de mA.',
    rows: [
      ComparisonRow('Corriente de carga', 'Pocos mA', 'Hasta 1.5 A'),
      ComparisonRow('Regulación', 'Moderada', 'Muy buena'),
      ComparisonRow('Consumo sin carga', 'Alto (circula por Rs)', 'Bajo (corriente de reposo)'),
      ComparisonRow('Componentes externos', 'Resistor serie', 'Dos capacitores'),
    ],
  ),
  CuratedComparison(
    aId: 'resistor',
    bId: 'potentiometer',
    keyDifference:
        'El resistor fija un valor; el potenciómetro permite ajustarlo, pero '
        'no soporta potencia.',
    chooseAWhen: 'El valor está definido por el diseño.',
    chooseBWhen: 'Una persona debe ajustar o calibrar el nivel.',
    rows: [
      ComparisonRow('Terminales', '2', '3 (con cursor)'),
      ComparisonRow('Valor', 'Fijo', 'Variable'),
      ComparisonRow('Potencia', 'Desde 1/8 W hasta decenas de W', 'Baja (≈ 0.1 W a 0.5 W)'),
      ComparisonRow('Desgaste', 'Ninguno', 'Mecánico, por uso'),
    ],
  ),
  CuratedComparison(
    aId: 'diode_rectifier',
    bId: 'led',
    keyDifference:
        'Ambos son diodos, pero el LED está optimizado para emitir luz y '
        'soporta muy poca tensión inversa.',
    chooseAWhen: 'Rectificar o proteger circuitos de potencia.',
    chooseBWhen: 'Indicar estados o iluminar.',
    rows: [
      ComparisonRow('Tensión directa', '≈ 0.7 V', '1.8 V a 3.3 V'),
      ComparisonRow('Tensión inversa máxima', 'Hasta 1000 V', '≈ 5 V'),
      ComparisonRow('Corriente típica', 'Hasta 1 A o más', '5 mA a 20 mA'),
      ComparisonRow('Emite luz', 'No', 'Sí'),
    ],
  ),
];
