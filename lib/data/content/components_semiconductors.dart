import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';

/// Módulo 3 — Semiconductores.
const List<ElectronicComponent> semiconductorComponents = [
  ElectronicComponent(
    id: 'diode_rectifier',
    name: 'Diodo rectificador',
    shortName: 'Diodo',
    category: ComponentCategory.semiconductor,
    symbol: SymbolType.diode,
    example: '1N4007 (1 A, 1000 V)',
    summary: 'Deja pasar la corriente en un solo sentido.',
    howItWorks:
        'Una unión PN crea una zona de agotamiento que actúa como barrera. '
        'En polarización directa (ánodo más positivo que cátodo), una tensión '
        'cercana a 0.7 V en silicio vence la barrera y la corriente crece de '
        'forma exponencial. En polarización inversa la barrera se ensancha y '
        'solo circula una corriente de fuga mínima, hasta la tensión de ruptura.',
    keyFormula: 'I = Is · (e^(V / (n·VT)) − 1)    VF ≈ 0.7 V (silicio)',
    characteristics: [
      Characteristic(
        name: 'Corriente directa media (IF)',
        value: '1 A (1N4007), 3 A (1N5408)',
        note: 'Debe superar la corriente de la carga con margen.',
      ),
      Characteristic(
        name: 'Tensión inversa máxima (VRRM)',
        value: '50 V a 1000 V',
        note: 'Debe superar el pico inverso del circuito.',
      ),
      Characteristic(
        name: 'Caída directa (VF)',
        value: '0.7 V a 1.1 V',
        note: 'Los Schottky caen entre 0.2 y 0.45 V.',
      ),
      Characteristic(
        name: 'Tiempo de recuperación inversa',
        value: 'µs (estándar), ns (rápidos)',
        note: 'En fuentes conmutadas se requieren diodos rápidos o Schottky.',
      ),
    ],
    applications: [
      'Rectificadores de media onda y de puente completo.',
      'Protección contra inversión de polaridad.',
      'Diodo de rueda libre en relés y motores.',
      'Compuertas lógicas simples y recortadores de señal.',
    ],
    useWhen: [
      'Debes convertir alterna en continua pulsante.',
      'Quieres impedir que la corriente circule en sentido contrario.',
    ],
    avoidWhen: [
      'Quieres fijar una tensión de referencia: usa un Zener.',
      'La caída de 0.7 V desperdicia demasiada energía en baja tensión: usa un Schottky.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Colocarlo al revés.',
        consequence: 'El circuito no recibe alimentación o el diodo bloquea la señal.',
        correction: 'La franja del cuerpo marca el cátodo; la flecha del '
            'símbolo apunta al cátodo.',
      ),
      CommonMistake(
        mistake: 'Olvidar la caída de tensión en los cálculos.',
        consequence: 'Un puente rectificador entrega casi 1.4 V menos de lo esperado.',
        correction: 'Resta VF por cada diodo que conduce en el camino de la corriente.',
      ),
      CommonMistake(
        mistake: 'Usar un diodo lento en alta frecuencia.',
        consequence: 'Conduce en inversa durante la recuperación y se calienta.',
        correction: 'Elige diodos rápidos o Schottky para conmutación.',
      ),
    ],
    identificationTips: [
      'Cilindro negro con una franja gris o plateada en el cátodo.',
      'Código impreso: 1N4001 a 1N4007, 1N5819 (Schottky).',
      'Los puentes rectificadores integran cuatro diodos en un encapsulado con marcas + y ~.',
    ],
    packages: ['DO-41', 'DO-201', 'SMA/SMB', 'Puente rectificador'],
    traits: {
      TraitKeys.function: 'Conducir en un solo sentido',
      TraitKeys.polarity: 'Polarizado (ánodo y cátodo)',
      TraitKeys.keyMagnitude: 'IF, VRRM y VF',
      TraitKeys.typicalRange: '1 A – 6 A; 50 V – 1000 V',
      TraitKeys.response: 'Exponencial en directa, bloquea en inversa',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'diode_forward',
  ),
  ElectronicComponent(
    id: 'diode_zener',
    name: 'Diodo Zener',
    shortName: 'Zener',
    category: ComponentCategory.semiconductor,
    symbol: SymbolType.zener,
    example: '1N4733A (5.1 V, 1 W) o BZX55C5V1 (0.5 W)',
    summary: 'Diodo diseñado para trabajar en ruptura inversa y mantener una tensión fija.',
    howItWorks:
        'Su unión está muy dopada para que la ruptura inversa ocurra a una '
        'tensión precisa y sin dañarse. Mientras circule una corriente '
        'inversa entre su mínimo y su máximo, la tensión entre sus terminales '
        'se mantiene casi constante. Por eso siempre necesita un resistor '
        'serie que limite esa corriente.',
    keyFormula: 'Rs = (Vin − Vz) / (Iz + IL)    Pz = Vz · Iz',
    characteristics: [
      Characteristic(
        name: 'Tensión Zener (Vz)',
        value: '2.4 V a 200 V',
        note: 'Tolerancia típica ±5 %.',
      ),
      Characteristic(
        name: 'Potencia máxima (Pz)',
        value: '0.5 W, 1 W, 5 W',
        note: 'Limita la corriente máxima: Iz(max) = Pz / Vz.',
      ),
      Characteristic(
        name: 'Corriente de prueba (IZT)',
        value: '5 mA a 50 mA',
        note: 'Por debajo de la corriente mínima la regulación empeora.',
      ),
      Characteristic(
        name: 'Resistencia dinámica (ZZT)',
        value: '2 Ω a 50 Ω',
        note: 'Cuanto menor, mejor regula.',
      ),
    ],
    applications: [
      'Referencias de tensión simples.',
      'Reguladores en paralelo para cargas de pocos mA.',
      'Protección de entradas contra sobretensión.',
      'Desplazamiento de niveles de tensión.',
    ],
    useWhen: [
      'Necesitas una referencia o regular una carga pequeña y constante.',
      'Quieres recortar una tensión que no debe superar cierto valor.',
    ],
    avoidWhen: [
      'La carga consume cientos de mA o varía mucho: usa un regulador lineal.',
      'Solo necesitas rectificar: un diodo rectificador es más adecuado.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectarlo sin resistor serie.',
        consequence: 'La corriente no tiene límite y el Zener se destruye.',
        correction: 'Calcula Rs para la peor condición de entrada y carga.',
      ),
      CommonMistake(
        mistake: 'Polarizarlo en directa esperando que regule.',
        consequence: 'Se comporta como un diodo normal: solo cae 0.7 V.',
        correction: 'El cátodo debe ir al positivo para trabajar en ruptura.',
      ),
      CommonMistake(
        mistake: 'Calcular Rs solo para la carga nominal.',
        consequence: 'Sin carga, toda la corriente pasa por el Zener y supera su potencia.',
        correction: 'Verifica también el caso sin carga y con entrada máxima.',
      ),
    ],
    identificationTips: [
      'Cuerpo de vidrio naranja o negro con franja en el cátodo.',
      'La tensión suele estar impresa con V como coma decimal (5V1 = 5.1 V).',
      'En el símbolo, la barra del cátodo tiene los extremos doblados.',
    ],
    packages: ['DO-35 (vidrio)', 'DO-41', 'SOT-23', 'SMA'],
    traits: {
      TraitKeys.function: 'Fijar una tensión de referencia',
      TraitKeys.polarity: 'Polarizado; trabaja en inversa',
      TraitKeys.keyMagnitude: 'Vz y Pz',
      TraitKeys.typicalRange: '2.4 V – 200 V; 0.5 W – 5 W',
      TraitKeys.response: 'Tensión casi constante en ruptura',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'zener_regulator',
  ),
  ElectronicComponent(
    id: 'led',
    name: 'Diodo LED',
    shortName: 'LED',
    category: ComponentCategory.semiconductor,
    symbol: SymbolType.led,
    example: 'LED rojo de 5 mm, 20 mA',
    summary: 'Diodo que emite luz al conducir en polarización directa.',
    howItWorks:
        'Al recombinarse electrones y huecos en la unión se libera energía en '
        'forma de fotones. El material semiconductor define el color y la '
        'tensión directa: los rojos caen cerca de 2 V y los azules o blancos, '
        'más de 3 V. Como la corriente crece de forma exponencial con la '
        'tensión, el LED se controla por corriente y necesita un limitador.',
    keyFormula: 'R = (Vcc − VF) / IF',
    characteristics: [
      Characteristic(
        name: 'Tensión directa (VF)',
        value: 'Rojo ≈ 2.0 V · Verde ≈ 3.0 V · Azul/Blanco ≈ 3.2 V',
        note: 'Depende del material; revisa la hoja de datos.',
      ),
      Characteristic(
        name: 'Corriente directa (IF)',
        value: '5 mA a 20 mA (indicadores)',
        note: 'Los LED de potencia trabajan con cientos de mA y disipador.',
      ),
      Characteristic(
        name: 'Tensión inversa máxima',
        value: '≈ 5 V',
        note: 'Mucho menor que en un diodo rectificador.',
      ),
      Characteristic(
        name: 'Ángulo de visión',
        value: '15° a 120°',
      ),
    ],
    applications: [
      'Indicadores de encendido y estado.',
      'Iluminación y pantallas.',
      'Optoacopladores y comunicación infrarroja.',
      'Señalización en tableros industriales.',
    ],
    useWhen: [
      'Necesitas indicar un estado con luz consumiendo poca energía.',
      'Requieres una fuente de luz eficiente y de larga vida.',
    ],
    avoidWhen: [
      'Debes rectificar potencia: su tensión inversa máxima es muy baja.',
      'Necesitas alimentarlo directo desde una batería sin limitador.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectarlo sin resistor limitador.',
        consequence: 'La corriente se dispara y el LED se quema en segundos.',
        correction: 'Calcula R = (Vcc − VF) / IF y elige el valor comercial superior.',
      ),
      CommonMistake(
        mistake: 'Usar un solo resistor para varios LED en paralelo.',
        consequence: 'El LED con menor VF acapara la corriente y se daña.',
        correction: 'Coloca un resistor por cada LED o conéctalos en serie.',
      ),
      CommonMistake(
        mistake: 'Usar la misma resistencia para un LED rojo y uno azul.',
        consequence: 'El azul brilla menos o no enciende con 3.3 V.',
        correction: 'Recalcula con la VF del color correspondiente.',
      ),
    ],
    identificationTips: [
      'Terminal largo: ánodo (+). Lado plano del encapsulado: cátodo (−).',
      'Dentro del encapsulado, la pieza metálica más grande suele ser el cátodo.',
      'En el símbolo aparecen dos flechas que salen del diodo.',
    ],
    packages: ['3 mm', '5 mm', 'SMD 0805', 'SMD 5050 (RGB)'],
    traits: {
      TraitKeys.function: 'Emitir luz',
      TraitKeys.polarity: 'Polarizado (ánodo y cátodo)',
      TraitKeys.keyMagnitude: 'VF, IF y color',
      TraitKeys.typicalRange: '1.8 V – 3.3 V; 5 mA – 20 mA',
      TraitKeys.response: 'Se controla por corriente',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'led_resistor',
  ),
  ElectronicComponent(
    id: 'bjt_npn',
    name: 'Transistor bipolar NPN',
    shortName: 'BJT NPN',
    category: ComponentCategory.semiconductor,
    symbol: SymbolType.bjtNpn,
    example: '2N2222A o BC547',
    summary:
        'Dispositivo controlado por corriente: una pequeña corriente de base controla una mayor de colector.',
    howItWorks:
        'Tiene tres regiones dopadas: emisor, base y colector. Cuando la '
        'unión base-emisor conduce (unos 0.7 V), la corriente de base permite '
        'que circule una corriente de colector β veces mayor. Tiene tres '
        'regiones de operación: corte (apagado), zona activa (amplificador) y '
        'saturación (interruptor cerrado).',
    keyFormula: 'IC = β · IB (zona activa)    IB = (Vin − 0.7) / RB',
    characteristics: [
      Characteristic(
        name: 'Ganancia de corriente (β o hFE)',
        value: '75 a 300',
        note: 'Varía mucho entre unidades y con la temperatura.',
      ),
      Characteristic(
        name: 'Corriente máxima de colector',
        value: '100 mA (BC547), 600 mA (2N2222A)',
        note: 'Define qué cargas puede manejar.',
      ),
      Characteristic(
        name: 'Tensión colector-emisor máxima',
        value: '40 V a 45 V',
      ),
      Characteristic(
        name: 'VCE de saturación',
        value: '0.1 V a 0.3 V',
        note: 'Determina la potencia disipada como interruptor.',
      ),
    ],
    applications: [
      'Encender relés, LED y zumbadores desde un microcontrolador.',
      'Amplificadores de señal pequeña.',
      'Fuentes de corriente y espejos de corriente.',
      'Etapas de salida de circuitos de audio.',
    ],
    useWhen: [
      'Conmutas cargas pequeñas (decenas a cientos de mA) con bajo costo.',
      'Necesitas amplificar señales analógicas de baja potencia.',
    ],
    avoidWhen: [
      'La carga consume más de 0.5 A: un MOSFET disipa mucho menos.',
      'La fuente de control no puede entregar corriente: un MOSFET casi no la consume.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Conectar la base directamente al microcontrolador.',
        consequence: 'La unión base-emisor absorbe corriente excesiva y daña ambos.',
        correction: 'Coloca siempre un resistor de base.',
      ),
      CommonMistake(
        mistake: 'Calcular RB con el β máximo.',
        consequence: 'Con un transistor de β bajo no satura y se calienta.',
        correction: 'Usa el β mínimo y fuerza la saturación con margen (β forzado ≈ 10 a 20).',
      ),
      CommonMistake(
        mistake: 'Confundir el orden de los terminales.',
        consequence: 'El transistor no conmuta o se daña.',
        correction: 'El orden cambia entre modelos (2N2222: EBC; BC547: CBE). '
            'Consulta siempre la hoja de datos.',
      ),
    ],
    identificationTips: [
      'Encapsulado TO-92 (media luna negra) o TO-18 (metálico).',
      'Tres terminales; el código está en la cara plana.',
      'En el símbolo NPN, la flecha del emisor apunta hacia afuera.',
    ],
    packages: ['TO-92', 'TO-18', 'SOT-23', 'TO-220 (potencia)'],
    traits: {
      TraitKeys.function: 'Amplificar o conmutar controlado por corriente',
      TraitKeys.polarity: 'Tres terminales: base, colector y emisor',
      TraitKeys.keyMagnitude: 'β, IC(max) y VCE(sat)',
      TraitKeys.typicalRange: '100 mA – 1 A (señal)',
      TraitKeys.response: 'Consume corriente de base',
      TraitKeys.cost: 'Muy bajo',
    },
    simulationId: 'bjt_switch',
  ),
  ElectronicComponent(
    id: 'mosfet_n',
    name: 'MOSFET de canal N',
    shortName: 'MOSFET N',
    category: ComponentCategory.semiconductor,
    symbol: SymbolType.mosfetN,
    example: 'IRLZ44N (nivel lógico) o IRF540N',
    summary:
        'Transistor controlado por tensión, ideal para conmutar corrientes altas con poca pérdida.',
    howItWorks:
        'La compuerta está aislada por una capa de óxido: no consume corriente '
        'en régimen estable. Al superar la tensión de umbral (Vth), el campo '
        'eléctrico forma un canal entre drenador y fuente. Con suficiente '
        'tensión de compuerta el canal se comporta como una resistencia muy '
        'pequeña, RDS(on), y el MOSFET disipa poca potencia.',
    keyFormula: 'P = ID² · RDS(on)    ID(sat) = k/2 · (VGS − Vth)²',
    characteristics: [
      Characteristic(
        name: 'Tensión de umbral (VGS(th))',
        value: '1 V a 4 V',
        note: 'Con Vth apenas empieza a conducir; no está encendido del todo.',
      ),
      Characteristic(
        name: 'RDS(on)',
        value: '5 mΩ a 1 Ω',
        note: 'Se especifica a una VGS concreta (por ejemplo, 4.5 V o 10 V).',
      ),
      Characteristic(
        name: 'Corriente máxima de drenador',
        value: '1 A a más de 100 A',
      ),
      Characteristic(
        name: 'Tensión drenador-fuente máxima',
        value: '20 V a 1000 V',
      ),
    ],
    applications: [
      'Control de motores, tiras LED y calefactores con PWM.',
      'Interruptores de carga en fuentes y baterías.',
      'Convertidores conmutados.',
      'Protección contra inversión de polaridad.',
    ],
    useWhen: [
      'Conmutas corrientes altas con pocas pérdidas.',
      'El circuito de control solo entrega tensión, no corriente.',
    ],
    avoidWhen: [
      'Solo tienes 3.3 V de control y el MOSFET no es de nivel lógico.',
      'Necesitas amplificar señales pequeñas de forma lineal y sencilla: '
          'un BJT es más fácil de polarizar.',
    ],
    mistakes: [
      CommonMistake(
        mistake: 'Suponer que conduce plenamente al superar Vth.',
        consequence: 'Queda en conducción parcial, se calienta y la carga recibe menos tensión.',
        correction: 'Revisa la RDS(on) a la VGS que realmente aplicas.',
      ),
      CommonMistake(
        mistake: 'Dejar la compuerta flotando.',
        consequence: 'El MOSFET se enciende al azar por cargas acumuladas.',
        correction: 'Coloca un resistor de 10 kΩ a 100 kΩ entre compuerta y fuente.',
      ),
      CommonMistake(
        mistake: 'Olvidar el diodo de rueda libre con cargas inductivas.',
        consequence: 'La sobretensión perfora el MOSFET.',
        correction: 'Coloca un diodo en antiparalelo con la bobina o el motor.',
      ),
    ],
    identificationTips: [
      'Encapsulado TO-220 con lengüeta metálica (conectada al drenador).',
      'Orden típico de terminales: compuerta, drenador, fuente (G-D-S).',
      'Los de nivel lógico suelen incluir «L» en el código (IRLZ44N).',
    ],
    packages: ['TO-220', 'TO-252', 'SOT-23', 'SO-8'],
    traits: {
      TraitKeys.function: 'Conmutar controlado por tensión',
      TraitKeys.polarity: 'Tres terminales: compuerta, drenador y fuente',
      TraitKeys.keyMagnitude: 'Vth, RDS(on) e ID(max)',
      TraitKeys.typicalRange: '1 A – 100 A',
      TraitKeys.response: 'Compuerta sin consumo en régimen estable',
      TraitKeys.cost: 'Bajo',
    },
    simulationId: 'mosfet_switch',
  ),
];
