import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';

/// Módulo 4 — Sensores.
const List<ElectronicComponent> sensorComponents = [
  ElectronicComponent(
    id: 'ldr',
    name: 'Fotorresistencia (LDR)',
    shortName: 'LDR',
    category: ComponentCategory.sensor,
    symbol: SymbolType.ldr,
    example: 'GL5528',
    summary: 'Resistencia que disminuye cuando aumenta la luz que recibe.',
    howItWorks:
        'Está hecha de sulfuro de cadmio, un semiconductor que libera '
        'portadores de carga cuando absorbe fotones. Con más luz hay más '
        'portadores y la resistencia baja: de cientos de kΩ en oscuridad a '
        'pocos cientos de ohmios a pleno sol. Como el microcontrolador mide '
        'tensión, se coloca en un divisor de tensión.',
    keyFormula: 'R ≈ R10 · (E / 10 lx)^(−γ)    Vout = Vcc · Rf / (R_LDR + Rf)',
    characteristics: [
      Characteristic(
        name: 'Resistencia a 10 lx',
        value: '8 kΩ a 20 kΩ (GL5528)',
      ),
      Characteristic(
        name: 'Resistencia en oscuridad',
        value: '≥ 1 MΩ',
      ),
      Characteristic(
        name: 'Tiempo de respuesta',
        value: '20 ms a 30 ms',
        note: 'Demasiado lento para comunicación óptica.',
      ),
      Characteristic(
        name: 'Precisión',
        value: 'Baja; gran dispersión entre unidades',
        note: 'Sirve para umbrales, no para medir iluminancia.',
      ),
    ],
    applications: [
      'Luces nocturnas automáticas.',
      'Detección de día y noche en alumbrado público.',
      'Ajuste automático de brillo en pantallas simples.',
    ],
    useWhen: [
      'Solo necesitas saber si hay mucha o poca luz.',
      'El costo debe ser mínimo y la velocidad no importa.',
    ],
    avoidWhen: [
      'Necesitas medir lux con precisión: usa un sensor digital de luz.',
      'Debes detectar pulsos de luz rápidos: usa un fotodiodo o un fototransistor.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectarla directamente a una entrada analógica sin resistor.',
        consequence: 'La entrada queda flotando y no hay lectura útil.',
        correction: 'Forma un divisor de tensión con un resistor fijo.',
      ),
      CommonMistake(
        mistake: 'Elegir el resistor fijo al azar.',
        consequence: 'La salida casi no cambia en el rango de interés.',
        correction: 'Usa un resistor similar a la resistencia de la LDR en el umbral buscado.',
      ),
      CommonMistake(
        mistake: 'Colocarla donde recibe la luz de la lámpara que controla.',
        consequence: 'El sistema oscila: enciende, se ilumina y se apaga.',
        correction: 'Aíslala ópticamente o agrega histéresis.',
      ),
    ],
    identificationTips: [
      'Disco con una pista en zigzag visible sobre la superficie.',
      'Dos terminales, sin polaridad.',
      'En el símbolo, un resistor con flechas que llegan desde afuera.',
    ],
    packages: ['Disco de 5 mm', 'Disco de 12 mm'],
    traits: {
      TraitKeys.function: 'Detectar nivel de luz',
      TraitKeys.polarity: 'Sin polaridad',
      TraitKeys.keyMagnitude: 'Resistencia según iluminancia',
      TraitKeys.typicalRange: '200 Ω – 1 MΩ',
      TraitKeys.response: 'Lenta y no lineal',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'ldr_divider',
  ),
  ElectronicComponent(
    id: 'ntc',
    name: 'Termistor NTC',
    shortName: 'NTC',
    category: ComponentCategory.sensor,
    symbol: SymbolType.ntc,
    example: 'NTC 10 kΩ, B = 3950',
    summary: 'Resistencia que disminuye al aumentar la temperatura.',
    howItWorks:
        'Es un óxido metálico semiconductor: al calentarse, más portadores '
        'quedan libres y la resistencia baja de forma exponencial. Su '
        'sensibilidad es alta, pero la relación con la temperatura no es '
        'lineal, así que se convierte con la ecuación Beta o con la de '
        'Steinhart-Hart.',
    keyFormula: 'R(T) = R25 · e^(B·(1/T − 1/T25))    (T en kelvin)',
    characteristics: [
      Characteristic(
        name: 'Resistencia a 25 °C (R25)',
        value: '1 kΩ, 10 kΩ, 100 kΩ',
      ),
      Characteristic(
        name: 'Coeficiente Beta',
        value: '3000 K a 4500 K',
        note: 'Define cuánto cambia la resistencia con la temperatura.',
      ),
      Characteristic(
        name: 'Rango de trabajo',
        value: '−40 °C a 125 °C',
      ),
      Characteristic(
        name: 'Constante de disipación',
        value: '1 mW/°C a 7 mW/°C',
        note: 'Indica cuánto se autocalienta por la corriente de medida.',
      ),
    ],
    applications: [
      'Termómetros y termostatos de bajo costo.',
      'Protección térmica de baterías y motores.',
      'Limitación de corriente de arranque en fuentes.',
    ],
    useWhen: [
      'Necesitas alta sensibilidad a bajo costo en un rango moderado.',
      'Puedes calibrar o linealizar por software.',
    ],
    avoidWhen: [
      'Necesitas una lectura lineal sin calibración: usa un LM35 o un sensor digital.',
      'Debes medir temperaturas muy altas: usa un termopar.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Convertir la lectura con una regla de tres.',
        consequence: 'El error crece mucho fuera del punto de calibración.',
        correction: 'Usa la ecuación Beta o una tabla del fabricante.',
      ),
      CommonMistake(
        mistake: 'Hacer circular mucha corriente por el termistor.',
        consequence: 'Se autocalienta y mide una temperatura mayor a la real.',
        correction: 'Usa resistores de divisor de valor alto y mide de forma intermitente.',
      ),
      CommonMistake(
        mistake: 'Confundir NTC con PTC.',
        consequence: 'La lógica del programa queda invertida.',
        correction: 'NTC baja su resistencia con el calor; PTC la sube.',
      ),
    ],
    identificationTips: [
      'Pequeña gota de epoxi, a veces dentro de una sonda metálica.',
      'Dos terminales, sin polaridad.',
      'En el símbolo, un resistor atravesado por una línea con la marca −t°.',
    ],
    packages: ['Gota de epoxi', 'Sonda metálica', 'SMD 0603'],
    traits: {
      TraitKeys.function: 'Medir temperatura',
      TraitKeys.polarity: 'Sin polaridad',
      TraitKeys.keyMagnitude: 'R25 y coeficiente Beta',
      TraitKeys.typicalRange: '−40 °C – 125 °C',
      TraitKeys.response: 'Alta sensibilidad, no lineal',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'ntc_divider',
  ),
  ElectronicComponent(
    id: 'lm35',
    name: 'Sensor de temperatura LM35',
    shortName: 'LM35',
    category: ComponentCategory.sensor,
    symbol: SymbolType.tempSensorIc,
    example: 'LM35DZ',
    summary: 'Sensor integrado que entrega 10 mV por cada grado Celsius.',
    howItWorks:
        'Aprovecha que la tensión base-emisor de un transistor cambia con la '
        'temperatura. Un circuito interno amplifica y calibra esa variación '
        'para que la salida sea lineal y directamente proporcional a los '
        'grados Celsius, sin necesidad de ajustes externos.',
    keyFormula: 'Vout = 10 mV/°C · T    T = Vout / 0.01',
    characteristics: [
      Characteristic(
        name: 'Sensibilidad',
        value: '10 mV/°C',
      ),
      Characteristic(
        name: 'Precisión',
        value: '±0.5 °C a 25 °C',
      ),
      Characteristic(
        name: 'Rango',
        value: '2 °C a 150 °C (configuración básica)',
        note: 'Para temperaturas negativas necesita fuente negativa.',
      ),
      Characteristic(
        name: 'Alimentación',
        value: '4 V a 30 V; consumo de 60 µA',
        note: 'El bajo consumo evita el autocalentamiento.',
      ),
    ],
    applications: [
      'Termómetros digitales con microcontrolador.',
      'Monitoreo de temperatura en tableros y equipos.',
      'Prácticas de adquisición de datos.',
    ],
    useWhen: [
      'Quieres una lectura lineal y calibrada con cálculo simple.',
      'El rango está entre 2 °C y 150 °C.',
    ],
    avoidWhen: [
      'El sistema trabaja con 3.3 V: el LM35 necesita al menos 4 V.',
      'El cable al microcontrolador es largo y ruidoso: usa un sensor digital.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Invertir los terminales de alimentación y tierra.',
        consequence: 'El sensor se calienta y se daña.',
        correction: 'Con la cara plana al frente: +Vs, salida, tierra.',
      ),
      CommonMistake(
        mistake: 'Leer la salida con un ADC de 10 bits a 5 V sin amplificar.',
        consequence: 'La resolución es de casi 0.5 °C por paso.',
        correction: 'Amplifica la señal o usa una referencia de ADC menor.',
      ),
      CommonMistake(
        mistake: 'Esperar lecturas bajo 2 °C con la configuración básica.',
        consequence: 'La salida se queda en cero.',
        correction: 'Usa la configuración con fuente negativa o un sensor distinto.',
      ),
    ],
    identificationTips: [
      'Encapsulado TO-92 igual al de un transistor: revisa el código impreso.',
      'Tres terminales: alimentación, salida y tierra.',
      'Se confunde fácilmente con un 2N2222 o un BC547.',
    ],
    packages: ['TO-92', 'TO-220', 'SOIC-8'],
    traits: {
      TraitKeys.function: 'Medir temperatura',
      TraitKeys.polarity: 'Alimentación, salida y tierra',
      TraitKeys.keyMagnitude: 'Sensibilidad de 10 mV/°C',
      TraitKeys.typicalRange: '2 °C – 150 °C',
      TraitKeys.response: 'Lineal y calibrado',
      TraitKeys.cost: 'Medio',
    },
    simulationId: 'lm35_adc',
  ),
  ElectronicComponent(
    id: 'hcsr04',
    name: 'Sensor ultrasónico HC-SR04',
    shortName: 'Ultrasónico',
    category: ComponentCategory.sensor,
    symbol: SymbolType.ultrasonic,
    example: 'Módulo HC-SR04',
    summary: 'Mide distancia calculando el tiempo de ida y vuelta de un pulso de ultrasonido.',
    howItWorks:
        'Al recibir un pulso de disparo de 10 µs, el emisor envía ocho ciclos '
        'de 40 kHz. El receptor detecta el eco y el módulo entrega un pulso '
        'cuya duración es el tiempo de ida y vuelta. Con la velocidad del '
        'sonido se calcula la distancia, dividiendo entre dos.',
    keyFormula: 'd = v · t / 2    v ≈ 331.3 + 0.606 · T (m/s)',
    characteristics: [
      Characteristic(
        name: 'Rango',
        value: '2 cm a 400 cm',
      ),
      Characteristic(
        name: 'Resolución',
        value: '≈ 3 mm',
      ),
      Characteristic(
        name: 'Ángulo de detección',
        value: '≈ 15°',
        note: 'Objetos fuera del cono no se detectan.',
      ),
      Characteristic(
        name: 'Alimentación',
        value: '5 V; salida de eco de 5 V',
        note: 'Con microcontroladores de 3.3 V se necesita un divisor en ECHO.',
      ),
    ],
    applications: [
      'Sensores de estacionamiento.',
      'Robots que evitan obstáculos.',
      'Medición de nivel de líquidos en tanques.',
    ],
    useWhen: [
      'Necesitas medir distancias sin contacto entre 2 cm y 4 m.',
      'El objeto es sólido y está de frente al sensor.',
    ],
    avoidWhen: [
      'El objeto es blando, pequeño o inclinado: el eco se pierde.',
      'Necesitas precisión milimétrica o gran velocidad: usa un sensor láser.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Olvidar dividir el tiempo entre dos.',
        consequence: 'La distancia calculada es el doble de la real.',
        correction: 'El pulso de eco mide ida y vuelta.',
      ),
      CommonMistake(
        mistake: 'Conectar ECHO directamente a una entrada de 3.3 V.',
        consequence: 'Se puede dañar el microcontrolador.',
        correction: 'Usa un divisor de tensión o un adaptador de niveles.',
      ),
      CommonMistake(
        mistake: 'Disparar mediciones sin pausa.',
        consequence: 'Ecos de la medición anterior producen lecturas falsas.',
        correction: 'Espera al menos 60 ms entre disparos.',
      ),
    ],
    identificationTips: [
      'Módulo azul con dos cilindros metálicos marcados T (emisor) y R (receptor).',
      'Cuatro pines: VCC, TRIG, ECHO y GND.',
    ],
    packages: ['Módulo de 4 pines'],
    traits: {
      TraitKeys.function: 'Medir distancia',
      TraitKeys.polarity: 'VCC, TRIG, ECHO y GND',
      TraitKeys.keyMagnitude: 'Tiempo de vuelo',
      TraitKeys.typicalRange: '2 cm – 400 cm',
      TraitKeys.response: 'Depende de la temperatura y la superficie',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'ultrasonic_tof',
  ),
];
