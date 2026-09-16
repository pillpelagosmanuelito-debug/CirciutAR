import '../../domain/models/assistant.dart';

/// Identificador del nodo inicial del asistente de selección.
const String assistantRootId = 'root';

/// Árbol de decisión del asistente de selección de componentes.
///
/// Es determinista a propósito: cada recomendación es revisable por un
/// docente y siempre da la misma respuesta ante la misma necesidad.
const List<AssistantNode> assistantTree = [
  AssistantNode(
    id: assistantRootId,
    question: '¿Qué necesitas lograr en tu circuito?',
    hint: 'Piensa en la función, no en el componente.',
    options: [
      AssistantOption('Limitar corriente o dividir una tensión', nextId: 'resistive'),
      AssistantOption('Filtrar, desacoplar o almacenar energía', nextId: 'storage'),
      AssistantOption('Controlar el sentido de la corriente o emitir luz', nextId: 'diodes'),
      AssistantOption('Encender o apagar una carga desde un control', nextId: 'switching'),
      AssistantOption('Obtener una tensión fija', nextId: 'regulation'),
      AssistantOption('Amplificar una señal pequeña', nextId: 'amplify'),
      AssistantOption('Generar pulsos o temporizar', nextId: 'timing'),
      AssistantOption('Medir una magnitud física', nextId: 'sensing'),
    ],
  ),
  AssistantNode(
    id: 'resistive',
    question: '¿El valor debe poder ajustarse a mano?',
    options: [
      AssistantOption(
        'No, el valor lo define el diseño',
        recommendation: Recommendation(
          componentId: 'resistor',
          reason:
              'Un resistor fija la relación entre tensión y corriente con '
              'mínimo costo.',
          checks: [
            'Calcula P = V²/R y elige al menos el doble de potencia nominal.',
            'Elige el valor comercial más cercano de la serie E12 o E24.',
            'Revisa la tolerancia si el circuito es de precisión.',
          ],
        ),
      ),
      AssistantOption(
        'Sí, una persona lo ajustará',
        recommendation: Recommendation(
          componentId: 'potentiometer',
          reason:
              'El potenciómetro forma un divisor ajustable con el cursor.',
          checks: [
            'La carga en el cursor debe ser al menos 10 veces mayor.',
            'No lo uses para manejar potencia.',
            'Elige curva lineal (B) salvo para audio (A).',
          ],
          alternativeId: 'resistor',
          alternativeNote: 'Si solo se calibra una vez, un trimmer y un resistor fijo en serie mejoran la resolución.',
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'storage',
    question: '¿Qué tipo de filtrado necesitas?',
    options: [
      AssistantOption(
        'Ruido de alta frecuencia junto a un integrado',
        recommendation: Recommendation(
          componentId: 'capacitor_ceramic',
          reason:
              'Su baja inductancia parásita absorbe picos rápidos de corriente.',
          checks: [
            'Valor típico: 100 nF por cada pin de alimentación.',
            'Colócalo lo más cerca posible del integrado.',
            'Tensión nominal por encima de la de trabajo.',
          ],
        ),
      ),
      AssistantOption(
        'Rizado de una fuente rectificada',
        recommendation: Recommendation(
          componentId: 'capacitor_electrolytic',
          reason:
              'Ofrece cientos o miles de µF en poco espacio para sostener la '
              'tensión entre pulsos.',
          checks: [
            'Capacidad a partir de C = I / (f · ΔV).',
            'Tensión nominal de al menos 1.5 veces el pico.',
            'Respeta la polaridad y complementa con un cerámico de 100 nF.',
          ],
          alternativeId: 'capacitor_ceramic',
          alternativeNote: 'Agrega un cerámico en paralelo para el ruido de alta frecuencia.',
        ),
      ),
      AssistantOption(
        'Oponerse a cambios bruscos de corriente',
        recommendation: Recommendation(
          componentId: 'inductor',
          reason:
              'El inductor almacena energía magnética y suaviza la corriente.',
          checks: [
            'Corriente de saturación mayor que el pico esperado.',
            'Resistencia de bobinado baja para reducir pérdidas.',
            'Protege el interruptor con un diodo de rueda libre.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'diodes',
    question: '¿Para qué necesitas controlar el sentido de la corriente?',
    options: [
      AssistantOption(
        'Rectificar o proteger contra polaridad inversa',
        recommendation: Recommendation(
          componentId: 'diode_rectifier',
          reason: 'Conduce en directa y bloquea tensiones inversas altas.',
          checks: [
            'IF mayor que la corriente de la carga.',
            'VRRM mayor que el pico inverso.',
            'En alta frecuencia, usa diodos rápidos o Schottky.',
          ],
        ),
      ),
      AssistantOption(
        'Fijar una tensión de referencia pequeña',
        recommendation: Recommendation(
          componentId: 'diode_zener',
          reason: 'En ruptura inversa mantiene una tensión casi constante.',
          checks: [
            'Resistor serie calculado para el peor caso.',
            'Pz mayor que Vz · Iz sin carga.',
            'Solo para cargas de pocos mA.',
          ],
          alternativeId: 'regulator_7805',
          alternativeNote: 'Si la carga consume más de unos mA, usa un regulador.',
        ),
      ),
      AssistantOption(
        'Indicar un estado con luz',
        recommendation: Recommendation(
          componentId: 'led',
          reason: 'Convierte corriente en luz con alta eficiencia.',
          checks: [
            'Resistor limitador R = (Vcc − VF) / IF.',
            'VF según el color.',
            'Un resistor por LED si van en paralelo.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'switching',
    question: '¿Cuánta corriente consume la carga?',
    hint: 'Un relé pequeño o un zumbador consumen decenas de mA; un motor o una tira LED, amperios.',
    options: [
      AssistantOption(
        'Menos de 200 mA',
        recommendation: Recommendation(
          componentId: 'bjt_npn',
          reason:
              'Un BJT de señal satura con poca corriente de base y es muy '
              'económico.',
          checks: [
            'RB calculado con β mínimo y margen de saturación.',
            'IC(max) del transistor mayor que la carga.',
            'Diodo de rueda libre si la carga es inductiva.',
          ],
          alternativeId: 'mosfet_n',
          alternativeNote: 'Un MOSFET de señal (2N7000) también sirve si hay 5 V de control.',
        ),
      ),
      AssistantOption('Más de 200 mA', nextId: 'switching_high'),
    ],
  ),
  AssistantNode(
    id: 'switching_high',
    question: '¿Qué tensión de control tienes disponible?',
    options: [
      AssistantOption(
        '3.3 V o 5 V (microcontrolador)',
        recommendation: Recommendation(
          componentId: 'mosfet_n',
          reason:
              'Un MOSFET de nivel lógico conduce plenamente con 3.3 o 5 V y '
              'disipa muy poco.',
          checks: [
            'RDS(on) especificada a 2.5 V o 4.5 V (nivel lógico).',
            'Resistor de compuerta a fuente de 10 kΩ a 100 kΩ.',
            'Diodo de rueda libre con motores o relés.',
          ],
        ),
      ),
      AssistantOption(
        '10 V o más',
        recommendation: Recommendation(
          componentId: 'mosfet_n',
          reason:
              'Con 10 V en la compuerta cualquier MOSFET de potencia conduce '
              'plenamente.',
          checks: [
            'No superar la VGS máxima (habitualmente ±20 V).',
            'Corriente y tensión máximas con margen.',
            'Disipador si ID² · RDS(on) supera 1 W.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'regulation',
    question: '¿Cuánta corriente necesita la carga?',
    options: [
      AssistantOption(
        'Pocos mA (referencia)',
        recommendation: Recommendation(
          componentId: 'diode_zener',
          reason: 'Un Zener con resistor serie basta para referencias simples.',
          checks: [
            'Corriente mínima de Zener en el peor caso.',
            'Potencia sin carga dentro del límite.',
          ],
        ),
      ),
      AssistantOption(
        'Decenas de mA hasta 1 A',
        recommendation: Recommendation(
          componentId: 'regulator_7805',
          reason:
              'El regulador lineal entrega una tensión estable y con poco '
              'ruido.',
          checks: [
            'Vin ≥ Vout + dropout (7 V para un 7805).',
            'P = (Vin − Vout) · I; disipador si supera 1 W.',
            'Capacitores de entrada y salida junto a los pines.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'amplify',
    question: '¿La señal proviene de un sensor o de una fuente delicada?',
    options: [
      AssistantOption(
        'Sí, no debo cargarla',
        recommendation: Recommendation(
          componentId: 'opamp',
          reason:
              'La configuración no inversora tiene impedancia de entrada muy '
              'alta y ganancia fijada por resistores.',
          checks: [
            'G = 1 + Rf/Rin.',
            'Vin · G dentro de la excursión de salida.',
            'Amplificador rail-to-rail si trabajas con 3.3 V.',
          ],
        ),
      ),
      AssistantOption(
        'No, necesito además invertir la señal',
        recommendation: Recommendation(
          componentId: 'opamp',
          reason: 'La configuración inversora da ganancia −Rf/Rin.',
          checks: [
            'La impedancia de entrada es Rin.',
            'Con alimentación simple, polariza la entrada no inversora.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'timing',
    question: '¿Tu sistema ya tiene un microcontrolador?',
    options: [
      AssistantOption(
        'No',
        recommendation: Recommendation(
          componentId: 'timer_555',
          reason:
              'El 555 genera pulsos o retardos con dos resistores y un '
              'capacitor.',
          checks: [
            'f = 1.44 / ((R1 + 2·R2) · C).',
            'Pin 4 conectado a la alimentación.',
            'Capacitor de 10 nF en el pin 5.',
          ],
        ),
      ),
      AssistantOption(
        'Sí',
        recommendation: Recommendation(
          componentId: 'timer_555',
          reason:
              'Usa los temporizadores del microcontrolador; el 555 solo se '
              'justifica si la función debe ser independiente del programa '
              '(por ejemplo, un vigilante).',
          checks: [
            'Evalúa si una función de hardware independiente aporta seguridad.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'sensing',
    question: '¿Qué magnitud quieres medir?',
    options: [
      AssistantOption(
        'Nivel de luz',
        recommendation: Recommendation(
          componentId: 'ldr',
          reason: 'Barata y suficiente para detectar umbrales de luz.',
          checks: [
            'Divisor con resistor fijo similar a la LDR en el umbral.',
            'Histéresis si controla una lámpara.',
          ],
        ),
      ),
      AssistantOption('Temperatura', nextId: 'sensing_temp'),
      AssistantOption(
        'Distancia sin contacto',
        recommendation: Recommendation(
          componentId: 'hcsr04',
          reason: 'Mide el tiempo de vuelo del ultrasonido entre 2 y 400 cm.',
          checks: [
            'Divisor en ECHO si el microcontrolador es de 3.3 V.',
            'Al menos 60 ms entre mediciones.',
            'Compensación por temperatura si necesitas precisión.',
          ],
        ),
      ),
    ],
  ),
  AssistantNode(
    id: 'sensing_temp',
    question: '¿Qué es más importante en tu diseño?',
    options: [
      AssistantOption(
        'Lectura lineal y directa en °C',
        recommendation: Recommendation(
          componentId: 'lm35',
          reason: 'Entrega 10 mV/°C calibrados de fábrica.',
          checks: [
            'Alimentación de al menos 4 V.',
            'Rango de 2 °C a 150 °C en configuración básica.',
            'Amplifica si la resolución del ADC no alcanza.',
          ],
          alternativeId: 'ntc',
          alternativeNote: 'Si el sistema es de 3.3 V, una NTC con calibración es más práctica.',
        ),
      ),
      AssistantOption(
        'Bajo costo, alta sensibilidad o temperaturas bajo cero',
        recommendation: Recommendation(
          componentId: 'ntc',
          reason: 'Muy sensible y económica; se linealiza por software.',
          checks: [
            'Ecuación Beta o tabla del fabricante.',
            'Resistores de valor alto para evitar autocalentamiento.',
          ],
        ),
      ),
    ],
  ),
];
