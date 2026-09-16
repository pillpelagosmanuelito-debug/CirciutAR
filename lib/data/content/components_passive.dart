import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';

/// Módulo 1 — Componentes pasivos.
const List<ElectronicComponent> passiveComponents = [
  ElectronicComponent(
    id: 'resistor',
    name: 'Resistor',
    shortName: 'Resistor',
    category: ComponentCategory.passive,
    symbol: SymbolType.resistor,
    example: 'Resistor de película de carbono de 1/4 W',
    summary:
        'Se opone al paso de la corriente y convierte energía eléctrica en calor.',
    howItWorks:
        'El material resistivo limita el número de cargas que atraviesan el '
        'componente por segundo. La tensión entre sus terminales es '
        'proporcional a la corriente (ley de Ohm) y la energía que se pierde '
        'se transforma en calor. Por eso un resistor tiene dos límites: su '
        'valor en ohmios y la potencia que puede disipar sin dañarse.',
    keyFormula: 'V = I · R    P = V · I = I² · R = V² / R',
    characteristics: [
      Characteristic(
        name: 'Resistencia nominal',
        value: '1 Ω a 10 MΩ',
        note: 'Se fabrica en series normalizadas (E12, E24, E96).',
      ),
      Characteristic(
        name: 'Tolerancia',
        value: '±1 % (película metálica), ±5 % (carbón)',
        note: 'Indica cuánto puede diferir el valor real del nominal.',
      ),
      Characteristic(
        name: 'Potencia nominal',
        value: '1/8 W, 1/4 W, 1/2 W, 1 W, 5 W…',
        note: 'Regla práctica: elegir al menos el doble de la potencia calculada.',
      ),
      Characteristic(
        name: 'Coeficiente de temperatura',
        value: '50 a 250 ppm/°C',
        note: 'Importa en instrumentación y referencias de precisión.',
      ),
    ],
    applications: [
      'Limitar la corriente de un LED o de la base de un transistor.',
      'Formar divisores de tensión para adaptar niveles de señal.',
      'Resistencias de pull-up y pull-down en entradas digitales.',
      'Fijar la ganancia de amplificadores operacionales.',
      'Medir corriente con un resistor shunt de bajo valor.',
    ],
    useWhen: [
      'Necesitas limitar corriente o fijar una relación tensión-corriente.',
      'Quieres dividir una tensión para una señal que consume muy poca corriente.',
    ],
    avoidWhen: [
      'Quieres alimentar una carga con tensión estable: un divisor cambia con '
          'la carga; usa un regulador.',
      'La potencia a disipar es grande de forma continua: el calor desperdicia '
          'energía; evalúa un convertidor conmutado.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Elegir solo por el valor en ohmios.',
        consequence: 'El resistor se sobrecalienta, cambia de valor o se quema.',
        correction: 'Calcula P = V²/R y elige una potencia nominal con margen.',
      ),
      CommonMistake(
        mistake: 'Leer las bandas desde el extremo equivocado.',
        consequence: 'Se obtiene un valor completamente distinto.',
        correction: 'La banda de tolerancia (dorada o plateada) va a la '
            'derecha y suele estar más separada.',
      ),
      CommonMistake(
        mistake: 'Medir la resistencia con el circuito energizado o conectado.',
        consequence: 'La lectura incluye caminos en paralelo o daña el multímetro.',
        correction: 'Desconecta la alimentación y levanta al menos un terminal.',
      ),
    ],
    identificationTips: [
      'Cuerpo cilíndrico con bandas de colores (montaje por orificio).',
      'En montaje superficial: código numérico de 3 o 4 dígitos (por ejemplo, '
          '472 = 4.7 kΩ).',
      'No tiene polaridad: se puede colocar en cualquier sentido.',
    ],
    packages: ['Axial', 'SMD 0603', 'SMD 0805', 'Potencia cerámica'],
    traits: {
      TraitKeys.function: 'Limitar corriente y dividir tensión',
      TraitKeys.polarity: 'Sin polaridad',
      TraitKeys.keyMagnitude: 'Resistencia (Ω) y potencia (W)',
      TraitKeys.typicalRange: '1 Ω – 10 MΩ',
      TraitKeys.response: 'Lineal: V proporcional a I',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'ohm_power',
  ),
  ElectronicComponent(
    id: 'potentiometer',
    name: 'Potenciómetro',
    shortName: 'Potenciómetro',
    category: ComponentCategory.passive,
    symbol: SymbolType.potentiometer,
    example: 'Potenciómetro lineal B10K',
    summary:
        'Resistor de tres terminales con un cursor que permite ajustar un divisor de tensión.',
    howItWorks:
        'Una pista resistiva une los dos terminales externos. El cursor se '
        'desliza sobre ella y divide la resistencia en dos partes, de modo que '
        'la tensión en el cursor es una fracción de la tensión aplicada. Si '
        'se usan solo dos terminales funciona como resistencia variable '
        '(reóstato).',
    keyFormula: 'Vout = Vin · α    (α = posición del cursor, de 0 a 1, sin carga)',
    characteristics: [
      Characteristic(
        name: 'Resistencia total',
        value: '1 kΩ a 1 MΩ',
        note: 'Valores típicos: 5 kΩ, 10 kΩ, 50 kΩ y 100 kΩ.',
      ),
      Characteristic(
        name: 'Curva',
        value: 'Lineal (B) o logarítmica (A)',
        note: 'La logarítmica se usa en control de volumen de audio.',
      ),
      Characteristic(
        name: 'Potencia',
        value: '0.1 W a 0.5 W',
        note: 'No sirve para manejar corrientes de carga.',
      ),
      Characteristic(
        name: 'Vida mecánica',
        value: '10 000 a 100 000 ciclos',
        note: 'Los trimmers soportan muchos menos ajustes.',
      ),
    ],
    applications: [
      'Perillas de volumen, brillo o velocidad.',
      'Entrada analógica de referencia para un microcontrolador.',
      'Ajuste fino de calibración (trimmer).',
      'Ajuste del contraste de una pantalla LCD.',
    ],
    useWhen: [
      'Una persona debe ajustar un nivel de forma manual.',
      'Necesitas calibrar un circuito una sola vez (trimmer multivuelta).',
    ],
    avoidWhen: [
      'Debes regular la potencia de un motor o una lámpara: el potenciómetro '
          'se quemaría; usa PWM con un transistor.',
      'El ajuste lo hará un programa: usa un potenciómetro digital o un DAC.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectar una carga de baja resistencia al cursor.',
        consequence: 'La tensión cae por efecto de carga y el ajuste deja de ser lineal.',
        correction: 'Usa una carga al menos 10 veces mayor o un seguidor de tensión.',
      ),
      CommonMistake(
        mistake: 'Usarlo en serie con un motor para regular su velocidad.',
        consequence: 'La pista disipa mucha potencia y se quema.',
        correction: 'Controla el motor con PWM y un transistor o MOSFET.',
      ),
      CommonMistake(
        mistake: 'Confundir el cursor con un extremo.',
        consequence: 'La salida no varía o varía al revés.',
        correction: 'El terminal central suele ser el cursor; verifica con el '
            'multímetro antes de soldar.',
      ),
    ],
    identificationTips: [
      'Tres terminales y un eje o ranura para girar.',
      'Código impreso: letra de curva y valor (B10K = lineal de 10 kΩ).',
      'Los trimmers son pequeños, cuadrados y se ajustan con destornillador.',
    ],
    packages: ['Rotativo de panel', 'Deslizante', 'Trimmer', 'Multivuelta'],
    traits: {
      TraitKeys.function: 'Ajustar manualmente un nivel',
      TraitKeys.polarity: 'Sin polaridad (el cursor es el terminal central)',
      TraitKeys.keyMagnitude: 'Resistencia total (Ω) y curva',
      TraitKeys.typicalRange: '1 kΩ – 1 MΩ',
      TraitKeys.response: 'Divisor ajustable, sensible a la carga',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'pot_divider',
  ),
  ElectronicComponent(
    id: 'capacitor_ceramic',
    name: 'Capacitor cerámico',
    shortName: 'Cerámico',
    category: ComponentCategory.passive,
    symbol: SymbolType.capacitorCeramic,
    example: 'Capacitor cerámico de 100 nF (código 104)',
    summary:
        'Almacena carga en un campo eléctrico; ideal para frecuencias altas y valores pequeños.',
    howItWorks:
        'Dos placas conductoras separadas por un dieléctrico cerámico '
        'acumulan carga cuando se aplica una tensión. La corriente solo '
        'circula mientras la tensión cambia, por eso bloquea la continua y '
        'deja pasar las variaciones. Su baja inductancia parásita lo hace '
        'ideal para absorber picos rápidos cerca de los circuitos integrados.',
    keyFormula: 'Q = C · V    i = C · dV/dt    τ = R · C    Xc = 1 / (2πfC)',
    characteristics: [
      Characteristic(
        name: 'Capacidad',
        value: '1 pF a 100 µF (multicapa)',
        note: 'Valores habituales: 22 pF, 100 nF y 1 µF.',
      ),
      Characteristic(
        name: 'Tensión nominal',
        value: '16 V a 1 kV',
        note: 'No debe superarse, ni siquiera en picos.',
      ),
      Characteristic(
        name: 'Dieléctrico',
        value: 'C0G/NP0 (estable), X7R, Y5V',
        note: 'X7R e Y5V pierden capacidad con la tensión y la temperatura.',
      ),
      Characteristic(
        name: 'Polaridad',
        value: 'No polarizado',
      ),
    ],
    applications: [
      'Desacoplo de 100 nF junto a cada circuito integrado.',
      'Filtros y redes de temporización de alta frecuencia.',
      'Capacitores de carga de cristales osciladores (C0G).',
      'Acoplamiento de señales entre etapas.',
    ],
    useWhen: [
      'Necesitas filtrar ruido de alta frecuencia o desacoplar un integrado.',
      'El valor es pequeño (pF a pocos µF) y no hay polaridad definida.',
    ],
    avoidWhen: [
      'Necesitas cientos o miles de µF para filtrar una fuente: usa un electrolítico.',
      'Buscas precisión de capacidad con X7R o Y5V: usa C0G o película.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Leer «104» como 104 pF.',
        consequence: 'Se elige un valor mil veces menor.',
        correction: 'Las dos primeras cifras son el valor y la tercera, los '
            'ceros: 104 = 10 × 10⁴ pF = 100 nF.',
      ),
      CommonMistake(
        mistake: 'Colocar el desacoplo lejos del integrado.',
        consequence: 'La inductancia de las pistas anula el filtro.',
        correction: 'Ubícalo lo más cerca posible de los pines de alimentación.',
      ),
      CommonMistake(
        mistake: 'Creer que conserva su capacidad con cualquier tensión.',
        consequence: 'Un X7R de 10 µF puede entregar menos de la mitad a su tensión nominal.',
        correction: 'Revisa la curva de capacidad frente a tensión en la hoja de datos.',
      ),
    ],
    identificationTips: [
      'Forma de lenteja o gota, normalmente color ocre o azul.',
      'Código de tres cifras en picofaradios (104, 223, 471).',
      'En montaje superficial no lleva marcas: se identifica por la lista de materiales.',
    ],
    packages: ['Disco', 'Multicapa radial', 'SMD 0402', 'SMD 0805'],
    traits: {
      TraitKeys.function: 'Desacoplar y filtrar alta frecuencia',
      TraitKeys.polarity: 'Sin polaridad',
      TraitKeys.keyMagnitude: 'Capacidad (F) y tensión nominal',
      TraitKeys.typicalRange: '1 pF – 100 µF',
      TraitKeys.response: 'Muy baja inductancia parásita',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'rc_charge',
  ),
  ElectronicComponent(
    id: 'capacitor_electrolytic',
    name: 'Capacitor electrolítico',
    shortName: 'Electrolítico',
    category: ComponentCategory.passive,
    symbol: SymbolType.capacitorElectrolytic,
    example: 'Electrolítico de aluminio de 1000 µF y 25 V',
    summary:
        'Capacitor polarizado de gran capacidad para filtrar fuentes y almacenar energía.',
    howItWorks:
        'Una lámina de aluminio con una capa de óxido muy delgada actúa como '
        'dieléctrico; el electrolito funciona como segunda placa. Esa capa '
        'delgada permite grandes capacidades en poco volumen, pero solo se '
        'mantiene si la tensión se aplica con la polaridad correcta.',
    keyFormula: 'ΔV ≈ I / (f · C)    (rizado de una fuente rectificada)',
    characteristics: [
      Characteristic(
        name: 'Capacidad',
        value: '0.1 µF a 100 000 µF',
        note: 'Tolerancia amplia, habitualmente ±20 %.',
      ),
      Characteristic(
        name: 'Tensión nominal',
        value: '6.3 V a 450 V',
        note: 'Elegir al menos 1.5 veces la tensión máxima de trabajo.',
      ),
      Characteristic(
        name: 'ESR',
        value: '0.01 Ω a varios Ω',
        note: 'Una ESR alta calienta el capacitor y empeora el filtrado.',
      ),
      Characteristic(
        name: 'Vida útil',
        value: '2000 a 10 000 h a 85 o 105 °C',
        note: 'Se duplica aproximadamente por cada 10 °C menos.',
      ),
    ],
    applications: [
      'Filtro de rizado después del rectificador en fuentes de alimentación.',
      'Reserva de energía a la entrada y salida de reguladores.',
      'Acoplamiento de audio de baja frecuencia.',
      'Temporizaciones largas con resistores de valor moderado.',
    ],
    useWhen: [
      'Necesitas mucha capacidad (cientos de µF o más) a baja frecuencia.',
      'La tensión en el capacitor tiene polaridad fija.',
    ],
    avoidWhen: [
      'La señal es alterna o cambia de polaridad: usa un no polarizado.',
      'Debes filtrar ruido de alta frecuencia: complementa con un cerámico de 100 nF.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectarlo con la polaridad invertida.',
        consequence: 'Se calienta, se hincha y puede explotar.',
        correction: 'La franja con signo menos marca el terminal negativo; el '
            'terminal largo es el positivo.',
      ),
      CommonMistake(
        mistake: 'Elegir una tensión nominal igual a la de trabajo.',
        consequence: 'Envejece rápido y falla con los picos de la red.',
        correction: 'Usa un margen de al menos 50 % (para 12 V, uno de 25 V).',
      ),
      CommonMistake(
        mistake: 'Tocar los terminales de un capacitor grande recién desconectado.',
        consequence: 'Puede conservar carga y producir una descarga peligrosa.',
        correction: 'Descárgalo con un resistor antes de manipularlo.',
      ),
    ],
    identificationTips: [
      'Cilindro con funda plástica y franja clara con signos menos (−).',
      'Capacidad y tensión impresas en el cuerpo (1000 µF 25 V).',
      'Terminal más largo: positivo. Muesca en forma de cruz en la parte superior.',
    ],
    packages: ['Radial', 'Axial', 'SMD de aluminio', 'Snap-in'],
    traits: {
      TraitKeys.function: 'Filtrar rizado y almacenar energía',
      TraitKeys.polarity: 'Polarizado',
      TraitKeys.keyMagnitude: 'Capacidad (F), tensión nominal y ESR',
      TraitKeys.typicalRange: '0.1 µF – 100 000 µF',
      TraitKeys.response: 'Gran capacidad, pobre en alta frecuencia',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'ripple_filter',
  ),
  ElectronicComponent(
    id: 'inductor',
    name: 'Inductor',
    shortName: 'Inductor',
    category: ComponentCategory.passive,
    symbol: SymbolType.inductor,
    example: 'Inductor de potencia de 100 µH y 2 A',
    summary:
        'Almacena energía en un campo magnético y se opone a los cambios de corriente.',
    howItWorks:
        'Un conductor enrollado crea un campo magnético cuando circula '
        'corriente. Si la corriente intenta cambiar, el campo induce una '
        'tensión que se opone al cambio (ley de Lenz). Por eso la corriente '
        'en un inductor no puede variar de forma instantánea y, al '
        'interrumpirla bruscamente, aparece una sobretensión.',
    keyFormula: 'v = L · di/dt    τ = L / R    XL = 2πfL    E = ½ · L · I²',
    characteristics: [
      Characteristic(
        name: 'Inductancia',
        value: '1 µH a 10 H',
        note: 'Se mide en henrios (H).',
      ),
      Characteristic(
        name: 'Corriente de saturación',
        value: '10 mA a decenas de A',
        note: 'Por encima de ella el núcleo se satura y la inductancia cae.',
      ),
      Characteristic(
        name: 'Resistencia de bobinado (DCR)',
        value: 'mΩ a decenas de Ω',
        note: 'Produce pérdidas por calor.',
      ),
      Characteristic(
        name: 'Frecuencia de autorresonancia',
        value: 'kHz a GHz',
        note: 'Por encima de ella se comporta como capacitor.',
      ),
    ],
    applications: [
      'Convertidores conmutados (buck, boost).',
      'Filtros LC para eliminar ruido de alimentación.',
      'Bobinas de relés, motores y solenoides.',
      'Circuitos sintonizados de radiofrecuencia.',
    ],
    useWhen: [
      'Necesitas almacenar energía en un convertidor conmutado.',
      'Quieres bloquear ruido de alta frecuencia dejando pasar la continua.',
    ],
    avoidWhen: [
      'Solo quieres limitar corriente continua: un resistor es más simple.',
      'El espacio es crítico y la frecuencia es baja: la inductancia necesaria sería enorme.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Interrumpir la corriente de una bobina sin protección.',
        consequence: 'La sobretensión destruye el transistor que la controla.',
        correction: 'Coloca un diodo de rueda libre en antiparalelo.',
      ),
      CommonMistake(
        mistake: 'Ignorar la corriente de saturación.',
        consequence: 'La inductancia cae, la corriente se dispara y el convertidor falla.',
        correction: 'Elige una corriente de saturación mayor que el pico esperado.',
      ),
      CommonMistake(
        mistake: 'Confundirlo con un resistor por su forma.',
        consequence: 'Se coloca un componente con comportamiento totalmente distinto.',
        correction: 'Los inductores axiales suelen ser más gruesos y verdes o '
            'azules; mide la continuidad y revisa el código.',
      ),
    ],
    identificationTips: [
      'Bobina visible sobre un núcleo toroidal o de ferrita.',
      'Los axiales parecen resistores gruesos con bandas de colores (en µH).',
      'Los SMD de potencia son cubos grises con un código como 101 (100 µH).',
    ],
    packages: ['Toroidal', 'Axial', 'SMD blindado', 'Radial de ferrita'],
    traits: {
      TraitKeys.function: 'Oponerse a cambios de corriente y almacenar energía',
      TraitKeys.polarity: 'Sin polaridad',
      TraitKeys.keyMagnitude: 'Inductancia (H) y corriente de saturación',
      TraitKeys.typicalRange: '1 µH – 10 H',
      TraitKeys.response: 'Genera sobretensión al cortar la corriente',
      TraitKeys.cost: 'Medio',
    },
    simulationId: 'rl_current',
  ),
];
