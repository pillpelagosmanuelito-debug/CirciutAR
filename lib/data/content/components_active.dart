import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';

/// Módulo 2 — Componentes activos (circuitos integrados de uso general).
const List<ElectronicComponent> activeComponents = [
  ElectronicComponent(
    id: 'opamp',
    name: 'Amplificador operacional',
    shortName: 'Amp. operacional',
    category: ComponentCategory.active,
    symbol: SymbolType.opAmp,
    example: 'LM358 (doble) o TL072',
    summary:
        'Amplificador diferencial de ganancia muy alta que, con realimentación, amplifica con precisión.',
    howItWorks:
        'Amplifica la diferencia entre sus entradas no inversora (+) e '
        'inversora (−) con una ganancia enorme. Con realimentación negativa '
        'el circuito se estabiliza cuando ambas entradas tienen casi la misma '
        'tensión, y la ganancia queda fijada solo por los resistores externos. '
        'Sin realimentación funciona como comparador. La salida nunca supera '
        'los límites de su alimentación.',
    keyFormula:
        'Inversor: G = −Rf / Rin    No inversor: G = 1 + Rf / Rin',
    characteristics: [
      Characteristic(
        name: 'Ganancia en lazo abierto',
        value: '10⁵ a 10⁶',
        note: 'Por eso se usa siempre con realimentación.',
      ),
      Characteristic(
        name: 'Producto ganancia-ancho de banda (GBW)',
        value: '1 MHz (LM358), 3 MHz (TL072)',
        note: 'Con ganancia 100, el ancho de banda se reduce a GBW/100.',
      ),
      Characteristic(
        name: 'Excursión de salida',
        value: 'Hasta 1.5 V de cada alimentación (no rail-to-rail)',
        note: 'Los rail-to-rail llegan casi a los extremos.',
      ),
      Characteristic(
        name: 'Alimentación',
        value: 'Simple (3 V a 32 V) o simétrica (±15 V)',
      ),
    ],
    applications: [
      'Amplificar la señal de sensores (acondicionamiento).',
      'Seguidor de tensión para no cargar una fuente de señal.',
      'Filtros activos y sumadores.',
      'Comparadores de umbral con histéresis.',
    ],
    useWhen: [
      'Una señal es demasiado pequeña para el conversor analógico-digital.',
      'Necesitas aislar una fuente de señal de una carga (seguidor).',
    ],
    avoidWhen: [
      'Debes entregar corriente a una carga (motor, parlante): usa una etapa de potencia.',
      'Necesitas comparar señales muy rápidas: usa un comparador dedicado.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Esperar una salida mayor que la alimentación.',
        consequence: 'La salida se satura y la señal se recorta.',
        correction: 'Verifica que Vin · G quede dentro de la excursión de salida.',
      ),
      CommonMistake(
        mistake: 'Confundir las entradas + y −.',
        consequence: 'La realimentación se vuelve positiva y la salida se va a un extremo.',
        correction: 'La realimentación negativa siempre vuelve a la entrada inversora (−).',
      ),
      CommonMistake(
        mistake: 'Dejar sin conectar los amplificadores no usados del integrado.',
        consequence: 'Oscilan y generan ruido y consumo extra.',
        correction: 'Configúralos como seguidores con la entrada a una tensión fija.',
      ),
    ],
    identificationTips: [
      'Circuito integrado DIP-8 o SOIC-8 con una muesca o punto en el pin 1.',
      'Códigos comunes: LM358, LM324, TL072, TL074, LM741.',
      'En el símbolo, triángulo con entradas marcadas + y −.',
    ],
    packages: ['DIP-8', 'SOIC-8', 'DIP-14 (cuádruple)', 'SOT-23-5'],
    traits: {
      TraitKeys.function: 'Amplificar y acondicionar señales',
      TraitKeys.polarity: 'Requiere alimentación; entradas + y −',
      TraitKeys.keyMagnitude: 'GBW, excursión de salida y offset',
      TraitKeys.typicalRange: 'Ganancias de 1 a 1000',
      TraitKeys.response: 'Salida limitada por la alimentación',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'opamp_amplifier',
  ),
  ElectronicComponent(
    id: 'regulator_7805',
    name: 'Regulador lineal de tensión',
    shortName: 'Regulador 7805',
    category: ComponentCategory.active,
    symbol: SymbolType.regulator,
    example: 'LM7805 (5 V, 1.5 A) o AMS1117-3.3',
    summary:
        'Entrega una tensión fija y estable a partir de una tensión mayor y variable.',
    howItWorks:
        'Un transistor interno actúa como resistencia variable en serie con '
        'la carga. Un lazo de control compara la salida con una referencia '
        'interna y ajusta ese transistor para mantener la tensión constante. '
        'La diferencia entre entrada y salida, multiplicada por la corriente, '
        'se convierte en calor.',
    keyFormula: 'P = (Vin − Vout) · I    Vin(min) = Vout + Vdropout',
    characteristics: [
      Characteristic(
        name: 'Tensión de salida',
        value: '5 V (7805), 12 V (7812), 3.3 V (AMS1117-3.3)',
      ),
      Characteristic(
        name: 'Tensión de caída (dropout)',
        value: '≈ 2 V (7805), ≈ 1.1 V (AMS1117), < 0.3 V (LDO)',
        note: 'La entrada debe superar la salida al menos en este valor.',
      ),
      Characteristic(
        name: 'Corriente máxima',
        value: '1 A a 1.5 A',
        note: 'Limitada en la práctica por la temperatura.',
      ),
      Characteristic(
        name: 'Protecciones',
        value: 'Térmica y contra cortocircuito',
      ),
    ],
    applications: [
      'Alimentar microcontroladores y sensores desde un adaptador de 9 o 12 V.',
      'Fuentes de laboratorio simples.',
      'Posregulación de fuentes conmutadas para reducir ruido.',
    ],
    useWhen: [
      'Necesitas una tensión estable y con poco ruido para cargas moderadas.',
      'La diferencia entre entrada y salida es pequeña.',
    ],
    avoidWhen: [
      'La diferencia de tensión y la corriente son grandes: usa un convertidor buck.',
      'Funciona con baterías y la eficiencia es crítica.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Alimentarlo con una tensión menor a Vout + dropout.',
        consequence: 'La salida cae y deja de estar regulada.',
        correction: 'Para un 7805 usa al menos 7 V de entrada.',
      ),
      CommonMistake(
        mistake: 'Omitir los capacitores de entrada y salida.',
        consequence: 'El regulador puede oscilar.',
        correction: 'Coloca los capacitores recomendados (por ejemplo, 330 nF y 100 nF) cerca de los pines.',
      ),
      CommonMistake(
        mistake: 'Ignorar la potencia disipada.',
        consequence: 'Se activa la protección térmica y la salida se corta.',
        correction: 'Calcula P = (Vin − Vout) · I y agrega disipador si supera 1 W.',
      ),
    ],
    identificationTips: [
      'Encapsulado TO-220 con tres terminales: entrada, tierra y salida (7805).',
      'El número indica la tensión: 7805 = 5 V, 7812 = 12 V; 79xx son negativos.',
      'Los reguladores de 3.3 V en SMD suelen venir en SOT-223.',
    ],
    packages: ['TO-220', 'TO-92 (78L05)', 'SOT-223', 'TO-252'],
    traits: {
      TraitKeys.function: 'Entregar tensión fija regulada',
      TraitKeys.polarity: 'Entrada, tierra y salida',
      TraitKeys.keyMagnitude: 'Vout, dropout e I(max)',
      TraitKeys.typicalRange: '1 A – 1.5 A',
      TraitKeys.response: 'Convierte en calor la diferencia de tensión',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'regulator_7805',
  ),
  ElectronicComponent(
    id: 'timer_555',
    name: 'Temporizador 555',
    shortName: '555',
    category: ComponentCategory.active,
    symbol: SymbolType.timer555,
    example: 'NE555 o su versión CMOS TLC555',
    summary:
        'Circuito integrado que genera pulsos y temporizaciones a partir de un circuito RC.',
    howItWorks:
        'Dos comparadores vigilan la tensión de un capacitor externo y la '
        'comparan con 1/3 y 2/3 de la alimentación. Un biestable interno '
        'cambia la salida y activa un transistor de descarga. En modo '
        'astable el capacitor se carga y descarga continuamente y la salida '
        'es una onda cuadrada; en modo monoestable genera un único pulso.',
    keyFormula: 'f = 1.44 / ((R1 + 2·R2) · C)    T(monoestable) = 1.1 · R · C',
    characteristics: [
      Characteristic(
        name: 'Alimentación',
        value: '4.5 V a 16 V (NE555), desde 2 V (CMOS)',
      ),
      Characteristic(
        name: 'Corriente de salida',
        value: 'Hasta 200 mA',
        note: 'Puede encender un LED o un relé pequeño directamente.',
      ),
      Characteristic(
        name: 'Frecuencia máxima',
        value: '≈ 100 kHz',
      ),
      Characteristic(
        name: 'Ciclo de trabajo (astable básico)',
        value: 'Siempre mayor al 50 %',
        note: 'Se corrige con un diodo en paralelo con R2.',
      ),
    ],
    applications: [
      'Luces intermitentes y alarmas sonoras.',
      'Generación de PWM simple para regular brillo o velocidad.',
      'Retardos de encendido (monoestable).',
      'Eliminación de rebote en pulsadores.',
    ],
    useWhen: [
      'Necesitas una señal periódica o un retardo sin programar un microcontrolador.',
      'Buscas un circuito robusto, barato y de pocos componentes.',
    ],
    avoidWhen: [
      'Requieres temporizaciones muy precisas o largas: usa un cristal o un microcontrolador.',
      'El sistema ya tiene un microcontrolador con temporizadores libres.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Dejar el pin 4 (reset) sin conectar.',
        consequence: 'El integrado se reinicia al azar.',
        correction: 'Conecta el reset a la alimentación si no se usa.',
      ),
      CommonMistake(
        mistake: 'Usar un electrolítico con mucha fuga para tiempos largos.',
        consequence: 'La temporización real difiere mucho de la calculada.',
        correction: 'Usa capacitores de baja fuga o reduce C y aumenta R.',
      ),
      CommonMistake(
        mistake: 'Esperar un 50 % de ciclo de trabajo del astable básico.',
        consequence: 'La señal queda más tiempo en alto que en bajo.',
        correction: 'Agrega un diodo en paralelo con R2 o usa la variante de 50 %.',
      ),
    ],
    identificationTips: [
      'Circuito integrado DIP-8 con el código NE555, LM555 o TLC555.',
      'Pin 1 = tierra, pin 8 = alimentación, pin 3 = salida.',
      'Suele ir acompañado de un capacitor de 10 nF en el pin 5.',
    ],
    packages: ['DIP-8', 'SOIC-8', 'MSOP-8'],
    traits: {
      TraitKeys.function: 'Generar pulsos y retardos',
      TraitKeys.polarity: 'Requiere alimentación; 8 pines',
      TraitKeys.keyMagnitude: 'Frecuencia y ciclo de trabajo',
      TraitKeys.typicalRange: '0.1 Hz – 100 kHz',
      TraitKeys.response: 'Temporización definida por R y C',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'timer555_astable',
  ),
];
