import '../../domain/models/learning_module.dart';

const List<LearningModule> learningModules = [
  LearningModule(
    id: ModuleId.passive,
    number: 1,
    title: 'Componentes pasivos',
    subtitle: 'Resistores, potenciómetros, capacitores e inductores',
    category: ComponentCategory.passive,
    description:
        'Los componentes que no amplifican ni necesitan alimentación propia. '
        'Aprenderás a elegirlos por algo más que su valor: potencia, '
        'polaridad, tensión nominal y comportamiento en el tiempo.',
    objectives: [
      'Calcular la potencia de un resistor y elegir su potencia nominal.',
      'Reconocer el efecto de carga en un divisor de tensión.',
      'Diferenciar cuándo usar un capacitor cerámico o uno electrolítico.',
      'Explicar por qué un inductor genera sobretensiones.',
    ],
  ),
  LearningModule(
    id: ModuleId.active,
    number: 2,
    title: 'Componentes activos',
    subtitle: 'Amplificador operacional, regulador y temporizador',
    category: ComponentCategory.active,
    description:
        'Circuitos integrados de uso general que necesitan alimentación y '
        'controlan energía: amplifican, regulan o temporizan.',
    objectives: [
      'Calcular la ganancia de un amplificador y prever su saturación.',
      'Estimar el calor de un regulador lineal y decidir si necesita disipador.',
      'Dimensionar un 555 astable para una frecuencia dada.',
    ],
  ),
  LearningModule(
    id: ModuleId.semiconductors,
    number: 3,
    title: 'Semiconductores',
    subtitle: 'Diodos, Zener, LED, BJT y MOSFET',
    category: ComponentCategory.semiconductor,
    description:
        'Dispositivos basados en uniones PN que conducen en un sentido, '
        'emiten luz o funcionan como interruptores controlados.',
    objectives: [
      'Interpretar la curva I–V del diodo y su tensión de codo.',
      'Diseñar un regulador Zener respetando sus límites.',
      'Calcular el resistor limitador de un LED.',
      'Decidir entre BJT y MOSFET para conmutar una carga.',
    ],
  ),
  LearningModule(
    id: ModuleId.sensors,
    number: 4,
    title: 'Sensores',
    subtitle: 'Luz, temperatura y distancia',
    category: ComponentCategory.sensor,
    description:
        'Componentes que convierten una magnitud física en una señal '
        'eléctrica. Aprenderás a leerlos y a elegir el adecuado para cada '
        'necesidad.',
    objectives: [
      'Convertir un cambio de resistencia en tensión con un divisor.',
      'Comparar un sensor lineal (LM35) con uno no lineal (NTC).',
      'Calcular distancias a partir del tiempo de vuelo.',
    ],
  ),
  LearningModule(
    id: ModuleId.applications,
    number: 5,
    title: 'Aplicaciones reales',
    subtitle: 'Casos de diseño paso a paso',
    description:
        'Proyectos reales donde debes elegir, dimensionar y anticipar fallas. '
        'Cada decisión recibe una explicación, también cuando te equivocas.',
    objectives: [
      'Integrar varios componentes en un circuito funcional.',
      'Justificar cada elección con criterios técnicos.',
      'Anticipar los errores más costosos antes de armar.',
    ],
  ),
  LearningModule(
    id: ModuleId.assessments,
    number: 6,
    title: 'Evaluaciones',
    subtitle: 'Mide tu dominio por competencia',
    description:
        'Evaluaciones por módulo y una evaluación integral. Los resultados se '
        'registran por competencia: identificación, comprensión, selección y '
        'aplicación.',
    objectives: [
      'Identificar componentes por su símbolo y su encapsulado.',
      'Seleccionar el componente adecuado y justificarlo.',
      'Resolver cálculos de dimensionamiento.',
    ],
  ),
];
