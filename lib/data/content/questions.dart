import '../../domain/models/competency.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';
import '../../domain/models/question.dart';

/// Banco de preguntas de las evaluaciones.
///
/// Las preguntas numéricas no guardan la respuesta: la calcula la simulación
/// indicada en [NumericSpec].
const List<Question> questionBank = [
  // ───────────────────────── Módulo 1: pasivos ─────────────────────────
  Question(
    id: 'p_power_choice',
    module: ModuleId.passive,
    competency: Competency.selection,
    componentId: 'resistor',
    prompt:
        'Un resistor de 100 Ω se conecta a 12 V. ¿Qué potencia nominal '
        'eliges?',
    explanation: 'P = V²/R = 144/100 = 1.44 W. Con la regla del doble de '
        'margen, corresponde un resistor de al menos 3 W; entre las opciones, '
        'solo el de 5 W es seguro.',
    options: [
      AnswerOption('1/4 W',
          feedback: 'Disiparía casi seis veces su potencia nominal: se quemaría.'),
      AnswerOption('1 W',
          feedback: 'Menor que 1.44 W: se sobrecalentaría y fallaría.'),
      AnswerOption('2 W',
          feedback: 'Supera la potencia calculada, pero trabaja al 72 %: '
              'sin margen térmico suficiente.'),
      AnswerOption('5 W',
          correct: true,
          feedback: 'Correcto: trabaja al 29 % de su capacidad, con margen.'),
    ],
  ),
  Question(
    id: 'p_power_num',
    module: ModuleId.passive,
    competency: Competency.application,
    componentId: 'resistor',
    prompt:
        '¿Qué potencia disipa un resistor de 470 Ω conectado a 12 V? '
        'Responde en mW.',
    explanation: 'P = V²/R = 144 / 470 ≈ 306 mW. Un resistor de 1/4 W no es '
        'suficiente.',
    numeric: NumericSpec(
      simulationId: 'ohm_power',
      inputs: {'v': 12, 'r': 470, 'rating': 0.25},
      outputKey: 'p',
      unitLabel: 'mW',
      scale: 1e-3,
    ),
  ),
  Question(
    id: 'p_loading_num',
    module: ModuleId.passive,
    competency: Competency.application,
    componentId: 'potentiometer',
    prompt:
        'Un potenciómetro de 10 kΩ, alimentado con 5 V y con el cursor al '
        '50 %, alimenta una carga de 1 kΩ. ¿Qué tensión hay en el cursor? '
        'Responde en V.',
    explanation: 'La mitad inferior (5 kΩ) queda en paralelo con 1 kΩ: '
        '833 Ω. La salida es 5 · 833 / (5000 + 833) ≈ 0.71 V, no 2.5 V.',
    numeric: NumericSpec(
      simulationId: 'pot_divider',
      inputs: {'vin': 5, 'rpot': 10000, 'pos': 50, 'rload': 1000},
      outputKey: 'vout',
      unitLabel: 'V',
    ),
  ),
  Question(
    id: 'p_cap_choice',
    module: ModuleId.passive,
    competency: Competency.selection,
    componentId: 'capacitor_ceramic',
    prompt:
        '¿Qué capacitor colocas junto al pin de alimentación de un '
        'microcontrolador para filtrar ruido de conmutación?',
    explanation: 'El desacoplo necesita baja inductancia parásita: un '
        'cerámico de 100 nF lo más cerca posible del pin.',
    options: [
      AnswerOption('Electrolítico de 1000 µF',
          feedback: 'Tiene mucha capacidad, pero su inductancia y su ESR lo '
              'hacen lento para el ruido de alta frecuencia.'),
      AnswerOption('Cerámico de 100 nF',
          correct: true,
          feedback: 'Correcto: es la elección estándar para desacoplo.'),
      AnswerOption('Inductor de 100 µH',
          feedback: 'Un inductor en paralelo no filtra: cortocircuitaría la '
              'alimentación en continua.'),
      AnswerOption('Resistor de 100 Ω en paralelo',
          feedback: 'Solo consumiría corriente; no almacena energía para '
              'absorber picos.'),
    ],
  ),
  Question(
    id: 'p_electro_polarity',
    module: ModuleId.passive,
    competency: Competency.identification,
    componentId: 'capacitor_electrolytic',
    prompt:
        'En un capacitor electrolítico radial, ¿cómo se identifica el '
        'terminal negativo?',
    explanation: 'La franja con signos menos y el terminal más corto marcan '
        'el negativo.',
    options: [
      AnswerOption('Es el terminal más largo',
          feedback: 'El terminal largo es el positivo.'),
      AnswerOption('Por la franja con signos menos en la funda',
          correct: true,
          feedback: 'Correcto: esa franja está del lado del terminal negativo.'),
      AnswerOption('No tiene polaridad',
          feedback: 'Los electrolíticos de aluminio son polarizados.'),
      AnswerOption('Por la muesca en cruz de la parte superior',
          feedback: 'La muesca es una válvula de seguridad, no indica '
              'polaridad.'),
    ],
  ),
  Question(
    id: 'p_ripple_num',
    module: ModuleId.passive,
    competency: Competency.application,
    componentId: 'capacitor_electrolytic',
    prompt:
        'Una fuente de onda completa (red de 60 Hz) entrega 500 mA con un '
        'capacitor de 2200 µF. ¿Cuál es el rizado pico a pico? Responde en V.',
    explanation: 'ΔV = I / (f · C) con f = 120 Hz: 0.5 / (120 · 0.0022) ≈ 1.89 V.',
    numeric: NumericSpec(
      simulationId: 'ripple_filter',
      inputs: {'vp': 12, 'iload': 500, 'c': 2200, 'mode': 1},
      outputKey: 'ripple',
      unitLabel: 'V',
    ),
  ),
  Question(
    id: 'p_tau_num',
    module: ModuleId.passive,
    competency: Competency.functional,
    componentId: 'capacitor_ceramic',
    prompt:
        'Un circuito RC tiene R = 10 kΩ y C = 100 µF. ¿Cuánto vale la '
        'constante de tiempo? Responde en s.',
    explanation: 'τ = R · C = 10 000 · 0.0001 = 1 s. En 5 τ (5 s) se '
        'considera cargado.',
    numeric: NumericSpec(
      simulationId: 'rc_charge',
      inputs: {'vs': 5, 'r': 10000, 'c': 100, 'tau': 1},
      outputKey: 'tau',
      unitLabel: 's',
    ),
  ),
  Question(
    id: 'p_inductor_flyback',
    module: ModuleId.passive,
    competency: Competency.functional,
    componentId: 'inductor',
    prompt:
        '¿Por qué se destruye un transistor que apaga la bobina de un relé '
        'sin ninguna protección?',
    explanation: 'Al cortar la corriente, v = L · di/dt produce un pico de '
        'tensión muy alto sobre el transistor.',
    options: [
      AnswerOption('Porque la bobina consume demasiada corriente al encender',
          feedback: 'La corriente de encendido crece gradualmente: el '
              'inductor se opone a cambios bruscos.'),
      AnswerOption('Porque aparece una sobretensión al interrumpir la corriente',
          correct: true,
          feedback: 'Correcto: por eso se coloca un diodo de rueda libre.'),
      AnswerOption('Porque la bobina se comporta como un capacitor',
          feedback: 'Solo ocurre por encima de su frecuencia de '
              'autorresonancia, no en un relé.'),
      AnswerOption('Porque la bobina invierte la polaridad de la fuente',
          feedback: 'La fuente no cambia; es la bobina la que genera la '
              'tensión inducida.'),
    ],
  ),

  // ───────────────────────── Módulo 2: activos ─────────────────────────
  Question(
    id: 'a_opamp_num',
    module: ModuleId.active,
    competency: Competency.application,
    componentId: 'opamp',
    prompt:
        'Un amplificador no inversor tiene Rf = 10 kΩ y Rin = 1 kΩ, con '
        '±12 V de alimentación. ¿Qué salida entrega con 0.5 V de entrada? '
        'Responde en V.',
    explanation: 'G = 1 + 10/1 = 11, entonces Vout = 5.5 V, dentro del '
        'límite de ±10.5 V.',
    numeric: NumericSpec(
      simulationId: 'opamp_amplifier',
      inputs: {'mode': 1, 'vin': 0.5, 'rf': 10000, 'rin': 1000, 'vcc': 12},
      outputKey: 'vout',
      unitLabel: 'V',
    ),
  ),
  Question(
    id: 'a_opamp_sat',
    module: ModuleId.active,
    competency: Competency.functional,
    componentId: 'opamp',
    prompt:
        'Con ganancia 11 y ±12 V de alimentación, ¿qué ocurre si la entrada '
        'es de 1.5 V?',
    explanation: 'La salida ideal sería 16.5 V, pero un amplificador no '
        'rail-to-rail se satura cerca de 10.5 V.',
    options: [
      AnswerOption('La salida es 16.5 V',
          feedback: 'La salida nunca supera la alimentación.'),
      AnswerOption('La salida se satura cerca de 10.5 V',
          correct: true,
          feedback: 'Correcto: la señal queda recortada.'),
      AnswerOption('La salida se invierte a −16.5 V',
          feedback: 'La configuración no inversora no cambia el signo.'),
      AnswerOption('El amplificador se destruye',
          feedback: 'La saturación no daña al integrado; solo distorsiona.'),
    ],
  ),
  Question(
    id: 'a_reg_num',
    module: ModuleId.active,
    competency: Competency.application,
    componentId: 'regulator_7805',
    prompt:
        'Un 7805 recibe 12 V y entrega 500 mA. ¿Qué potencia disipa? '
        'Responde en W.',
    explanation: 'P = (12 − 5) · 0.5 = 3.5 W: necesita disipador.',
    numeric: NumericSpec(
      simulationId: 'regulator_7805',
      inputs: {'vin': 12, 'iload': 500},
      outputKey: 'p',
      unitLabel: 'W',
    ),
  ),
  Question(
    id: 'a_reg_dropout',
    module: ModuleId.active,
    competency: Competency.selection,
    componentId: 'regulator_7805',
    prompt:
        'Necesitas 5 V estables a partir de una batería de 6 V. ¿Sirve un '
        '7805?',
    explanation: 'El 7805 necesita al menos 7 V de entrada. Con 6 V hace '
        'falta un regulador de baja caída (LDO).',
    options: [
      AnswerOption('Sí, porque 6 V es mayor que 5 V',
          feedback: 'No basta con que sea mayor: debe superar la salida en '
              'la tensión de caída (≈ 2 V).'),
      AnswerOption('No: necesita al menos 7 V; conviene un LDO',
          correct: true,
          feedback: 'Correcto: un LDO trabaja con caídas menores a 0.3 V.'),
      AnswerOption('Sí, si se agrega un disipador',
          feedback: 'El disipador resuelve el calor, no la falta de tensión.'),
      AnswerOption('No, porque la batería entrega corriente alterna',
          feedback: 'Las baterías entregan corriente continua.'),
    ],
  ),
  Question(
    id: 'a_555_num',
    module: ModuleId.active,
    competency: Competency.application,
    componentId: 'timer_555',
    prompt:
        'Un 555 astable tiene R1 = 10 kΩ, R2 = 68 kΩ y C = 10 µF. ¿Qué '
        'frecuencia genera? Responde en Hz.',
    explanation: 'f = 1 / (0.693 · (R1 + 2·R2) · C) ≈ 0.99 Hz: el LED '
        'parpadea una vez por segundo.',
    numeric: NumericSpec(
      simulationId: 'timer555_astable',
      inputs: {'r1': 10000, 'r2': 68000, 'c': 10},
      outputKey: 'f',
      unitLabel: 'Hz',
    ),
  ),
  Question(
    id: 'a_555_duty',
    module: ModuleId.active,
    competency: Competency.functional,
    componentId: 'timer_555',
    prompt:
        '¿Por qué el 555 astable básico no puede dar un ciclo de trabajo '
        'del 50 %?',
    explanation: 'El capacitor se carga por R1 + R2 y se descarga solo por '
        'R2, así que el tiempo en alto siempre es mayor.',
    options: [
      AnswerOption('Porque la carga pasa por R1 + R2 y la descarga solo por R2',
          correct: true,
          feedback: 'Correcto: un diodo en paralelo con R2 lo corrige.'),
      AnswerOption('Porque el pin de reset está conectado a la alimentación',
          feedback: 'El reset no influye en el ciclo de trabajo.'),
      AnswerOption('Porque el capacitor es electrolítico',
          feedback: 'El tipo de capacitor no cambia la relación entre tiempos.'),
      AnswerOption('Porque la salida tiene 200 mA como máximo',
          feedback: 'La corriente de salida no define los tiempos.'),
    ],
  ),

  // ─────────────────────── Módulo 3: semiconductores ───────────────────────
  Question(
    id: 's_led_num',
    module: ModuleId.semiconductors,
    competency: Competency.application,
    componentId: 'led',
    prompt:
        'Calcula el resistor para un LED rojo (VF = 2 V) alimentado con 5 V '
        'y 15 mA. Responde en Ω (valor calculado, sin redondear).',
    explanation: 'R = (5 − 2) / 0.015 = 200 Ω. El valor comercial E12 '
        'superior es 220 Ω.',
    numeric: NumericSpec(
      simulationId: 'led_resistor',
      inputs: {'vcc': 5, 'color': 0, 'if': 15},
      outputKey: 'r_calc',
      unitLabel: 'Ω',
    ),
  ),
  Question(
    id: 's_bjt_num',
    module: ModuleId.semiconductors,
    competency: Competency.application,
    componentId: 'bjt_npn',
    prompt:
        'Un NPN recibe 5 V en la base a través de 10 kΩ. ¿Cuál es la '
        'corriente de base? Responde en mA.',
    explanation: 'IB = (5 − 0.7) / 10 000 = 0.43 mA.',
    numeric: NumericSpec(
      simulationId: 'bjt_switch',
      inputs: {'vin': 5, 'rb': 10000, 'rc': 1000, 'vcc': 12, 'beta': 100},
      outputKey: 'ib',
      unitLabel: 'mA',
      scale: 1e-3,
    ),
  ),
  Question(
    id: 's_zener_num',
    module: ModuleId.semiconductors,
    competency: Competency.application,
    componentId: 'diode_zener',
    prompt:
        'Un Zener de 5.1 V con Rs = 220 Ω y 12 V de entrada alimenta una '
        'carga de 1 kΩ. ¿Qué corriente circula por el Zener? Responde en mA.',
    explanation: 'IRs = (12 − 5.1)/220 ≈ 31.4 mA; IL = 5.1 mA; '
        'IZ ≈ 26.3 mA.',
    numeric: NumericSpec(
      simulationId: 'zener_regulator',
      inputs: {'vin': 12, 'rs': 220, 'rl': 1000},
      outputKey: 'iz',
      unitLabel: 'mA',
      scale: 1e-3,
    ),
  ),
  Question(
    id: 's_switch_choice',
    module: ModuleId.semiconductors,
    competency: Competency.selection,
    componentId: 'mosfet_n',
    prompt:
        'Debes controlar con PWM una tira LED de 12 V y 3 A desde un '
        'microcontrolador de 3.3 V. ¿Qué eliges?',
    explanation: 'Con 3 A, un MOSFET de nivel lógico disipa muy poco y no '
        'exige corriente de control.',
    options: [
      AnswerOption('Un BC547',
          feedback: 'Su corriente máxima es 100 mA: se destruiría.'),
      AnswerOption('Un MOSFET de nivel lógico (por ejemplo, IRLZ44N)',
          correct: true,
          feedback: 'Correcto: conduce plenamente con 3.3 V y RDS(on) baja.'),
      AnswerOption('Un IRF540N conectado directamente al pin',
          feedback: 'No es de nivel lógico: con 3.3 V quedaría en '
              'conducción parcial y se calentaría.'),
      AnswerOption('Un diodo Zener',
          feedback: 'El Zener regula tensión; no conmuta cargas.'),
    ],
  ),
  Question(
    id: 's_bjt_region',
    module: ModuleId.semiconductors,
    competency: Competency.functional,
    componentId: 'bjt_npn',
    prompt:
        'Un transistor usado como interruptor tiene VCE = 6 V mientras la '
        'carga está encendida. ¿Qué indica?',
    explanation: 'En saturación VCE ≈ 0.2 V. Si es mayor, está en zona '
        'activa y disipa potencia.',
    options: [
      AnswerOption('Que está saturado correctamente',
          feedback: 'En saturación VCE sería cercana a 0.2 V.'),
      AnswerOption('Que está en corte',
          feedback: 'En corte no circula corriente y VCE sería igual a Vcc.'),
      AnswerOption('Que está en zona activa: falta corriente de base',
          correct: true,
          feedback: 'Correcto: reduce RB para saturarlo.'),
      AnswerOption('Que el transistor es PNP',
          feedback: 'El tipo no se deduce de VCE; el problema es la región.'),
    ],
  ),
  Question(
    id: 's_led_parallel',
    module: ModuleId.semiconductors,
    competency: Competency.selection,
    componentId: 'led',
    prompt:
        'Quieres encender cuatro LED en paralelo desde 5 V. ¿Qué configuración '
        'es correcta?',
    explanation: 'Cada LED tiene una VF ligeramente distinta; sin resistor '
        'propio, uno acapara la corriente.',
    options: [
      AnswerOption('Un solo resistor común para los cuatro',
          feedback: 'El LED con menor VF conduciría casi toda la corriente.'),
      AnswerOption('Un resistor en serie con cada LED',
          correct: true,
          feedback: 'Correcto: cada rama limita su propia corriente.'),
      AnswerOption('Sin resistores, porque 5 V es poca tensión',
          feedback: 'Sin limitador la corriente se dispara y los LED se queman.'),
      AnswerOption('Un Zener en paralelo con los LED',
          feedback: 'No limita la corriente de cada LED.'),
    ],
  ),
  Question(
    id: 's_diode_orientation',
    module: ModuleId.semiconductors,
    competency: Competency.identification,
    componentId: 'diode_rectifier',
    prompt: '¿Qué indica la franja gris en el cuerpo de un 1N4007?',
    explanation: 'La franja marca el cátodo, igual que la barra del símbolo.',
    options: [
      AnswerOption('El ánodo',
          feedback: 'El ánodo es el extremo sin franja.'),
      AnswerOption('El cátodo',
          correct: true,
          feedback: 'Correcto: la corriente convencional sale por ahí en directa.'),
      AnswerOption('La tensión máxima',
          feedback: 'La tensión figura en el código, no en la franja.'),
      AnswerOption('Que es un Zener',
          feedback: 'Todos los diodos axiales llevan franja en el cátodo.'),
    ],
  ),

  // ───────────────────────── Módulo 4: sensores ─────────────────────────
  Question(
    id: 'n_lm35_num',
    module: ModuleId.sensors,
    competency: Competency.application,
    componentId: 'lm35',
    prompt: '¿Qué tensión entrega un LM35 a 37 °C? Responde en mV.',
    explanation: 'Vout = 10 mV/°C · 37 °C = 370 mV.',
    numeric: NumericSpec(
      simulationId: 'lm35_adc',
      inputs: {'t': 37, 'vref': 0},
      outputKey: 'vout',
      unitLabel: 'mV',
      scale: 1e-3,
    ),
  ),
  Question(
    id: 'n_echo_num',
    module: ModuleId.sensors,
    competency: Competency.application,
    componentId: 'hcsr04',
    prompt:
        'Un objeto está a 50 cm de un HC-SR04, con aire a 20 °C. ¿Cuánto '
        'dura el pulso de eco? Responde en ms.',
    explanation: 'v = 331.3 + 0.606 · 20 ≈ 343.4 m/s; t = 2 · 0.5 / 343.4 '
        '≈ 2.91 ms.',
    numeric: NumericSpec(
      simulationId: 'ultrasonic_tof',
      inputs: {'d': 50, 't': 20},
      outputKey: 'echo',
      unitLabel: 'ms',
      scale: 1e-3,
    ),
  ),
  Question(
    id: 'n_ntc_num',
    module: ModuleId.sensors,
    competency: Competency.functional,
    componentId: 'ntc',
    prompt:
        'Una NTC de 10 kΩ a 25 °C forma un divisor con un resistor de 10 kΩ '
        'y 5 V. ¿Qué tensión hay en la salida a 25 °C? Responde en V.',
    explanation: 'A 25 °C la NTC vale 10 kΩ: el divisor es simétrico y la '
        'salida es 2.5 V.',
    numeric: NumericSpec(
      simulationId: 'ntc_divider',
      inputs: {'t': 25, 'beta': 3950, 'rf': 10000},
      outputKey: 'vout',
      unitLabel: 'V',
    ),
  ),
  Question(
    id: 'n_temp_choice',
    module: ModuleId.sensors,
    competency: Competency.selection,
    componentId: 'lm35',
    prompt:
        'Para una práctica de adquisición de datos con una placa de 5 V, '
        'necesitas leer la temperatura ambiente en °C sin calibrar. ¿Qué '
        'sensor eliges?',
    explanation: 'El LM35 entrega 10 mV/°C calibrados; basta dividir la '
        'tensión entre 0.01.',
    options: [
      AnswerOption('NTC de 10 kΩ',
          feedback: 'Funciona, pero exige la ecuación Beta o una tabla.'),
      AnswerOption('LM35',
          correct: true,
          feedback: 'Correcto: lineal, calibrado y compatible con 5 V.'),
      AnswerOption('LDR',
          feedback: 'La LDR responde a la luz, no a la temperatura.'),
      AnswerOption('HC-SR04',
          feedback: 'Mide distancia; la temperatura solo afecta su precisión.'),
    ],
  ),
  Question(
    id: 'n_ldr_choice',
    module: ModuleId.sensors,
    competency: Competency.functional,
    componentId: 'ldr',
    prompt:
        'Una LDR va de 5 V a la salida y un resistor fijo, de la salida a '
        'tierra. ¿Qué ocurre con la salida al oscurecer?',
    explanation: 'En oscuridad la LDR aumenta su resistencia, así que la '
        'fracción de tensión sobre el resistor fijo disminuye.',
    options: [
      AnswerOption('Aumenta',
          feedback: 'Aumentaría si la LDR estuviera en la parte inferior del divisor.'),
      AnswerOption('Disminuye',
          correct: true,
          feedback: 'Correcto: la LDR se hace más resistiva y toma más tensión.'),
      AnswerOption('No cambia',
          feedback: 'Cambia porque la resistencia de la LDR depende de la luz.'),
      AnswerOption('Se invierte de polaridad',
          feedback: 'Un divisor resistivo no invierte la polaridad.'),
    ],
  ),
  Question(
    id: 'n_ultra_3v3',
    module: ModuleId.sensors,
    competency: Competency.application,
    componentId: 'hcsr04',
    prompt:
        'Conectas un HC-SR04 a un microcontrolador de 3.3 V. ¿Qué precaución '
        'es necesaria?',
    explanation: 'El pin ECHO entrega 5 V, que pueden dañar una entrada de '
        '3.3 V.',
    options: [
      AnswerOption('Un divisor de tensión en el pin ECHO',
          correct: true,
          feedback: 'Correcto: baja el pulso de 5 V a un nivel seguro.'),
      AnswerOption('Un capacitor en el pin TRIG',
          feedback: 'TRIG es una entrada del módulo; 3.3 V suelen bastar.'),
      AnswerOption('Alimentar el módulo con 3.3 V',
          feedback: 'El HC-SR04 clásico necesita 5 V para funcionar.'),
      AnswerOption('Ninguna',
          feedback: 'La salida de 5 V puede dañar el microcontrolador.'),
    ],
  ),

  // ───────────────────── Identificación de símbolos ─────────────────────
  Question(
    id: 'id_zener',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'diode_zener',
    symbol: SymbolType.zener,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'La barra del cátodo con extremos doblados identifica al Zener.',
    options: [
      AnswerOption('Diodo rectificador',
          feedback: 'El rectificador tiene una barra recta.'),
      AnswerOption('Diodo Zener',
          correct: true,
          feedback: 'Correcto: los extremos doblados son su marca.'),
      AnswerOption('LED',
          feedback: 'El LED muestra flechas que salen del diodo.'),
      AnswerOption('Capacitor electrolítico',
          feedback: 'El capacitor se dibuja con dos placas.'),
    ],
  ),
  Question(
    id: 'id_mosfet',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'mosfet_n',
    symbol: SymbolType.mosfetN,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'La compuerta separada del canal indica que está aislada: es un MOSFET.',
    options: [
      AnswerOption('Transistor NPN',
          feedback: 'El BJT tiene la base unida a una barra y la flecha en el emisor.'),
      AnswerOption('MOSFET de canal N',
          correct: true,
          feedback: 'Correcto: la compuerta no toca el canal.'),
      AnswerOption('Amplificador operacional',
          feedback: 'El amplificador se dibuja como un triángulo.'),
      AnswerOption('Regulador de tensión',
          feedback: 'El regulador se dibuja como un bloque con entrada y salida.'),
    ],
  ),
  Question(
    id: 'id_electrolytic',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'capacitor_electrolytic',
    symbol: SymbolType.capacitorElectrolytic,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'Una placa curva o el signo + indican un capacitor polarizado.',
    options: [
      AnswerOption('Capacitor cerámico',
          feedback: 'El cerámico se dibuja con dos placas rectas y sin signo.'),
      AnswerOption('Capacitor electrolítico',
          correct: true,
          feedback: 'Correcto: el signo + marca la polaridad.'),
      AnswerOption('Batería',
          feedback: 'La batería alterna placas largas y cortas.'),
      AnswerOption('Inductor',
          feedback: 'El inductor se dibuja con espiras.'),
    ],
  ),
  Question(
    id: 'id_ldr',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'ldr',
    symbol: SymbolType.ldr,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'Un resistor con flechas entrantes es una fotorresistencia.',
    options: [
      AnswerOption('LED',
          feedback: 'En el LED las flechas salen y el cuerpo es un diodo.'),
      AnswerOption('Potenciómetro',
          feedback: 'El potenciómetro tiene una flecha que apunta al cuerpo '
              'como cursor, no rayos de luz.'),
      AnswerOption('Fotorresistencia (LDR)',
          correct: true,
          feedback: 'Correcto: las flechas representan la luz que recibe.'),
      AnswerOption('Termistor NTC',
          feedback: 'La NTC se marca con una línea diagonal y −t°.'),
    ],
  ),
  Question(
    id: 'id_opamp',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'opamp',
    symbol: SymbolType.opAmp,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'Un triángulo con entradas + y − es un amplificador operacional.',
    options: [
      AnswerOption('Amplificador operacional',
          correct: true,
          feedback: 'Correcto: el triángulo apunta hacia la salida.'),
      AnswerOption('Diodo',
          feedback: 'El diodo tiene un triángulo pequeño con una barra.'),
      AnswerOption('Temporizador 555',
          feedback: 'El 555 se dibuja como un bloque rectangular con pines numerados.'),
      AnswerOption('Transistor',
          feedback: 'El transistor se dibuja dentro de un círculo, con tres terminales.'),
    ],
  ),
  Question(
    id: 'id_potentiometer',
    module: ModuleId.assessments,
    competency: Competency.identification,
    componentId: 'potentiometer',
    symbol: SymbolType.potentiometer,
    prompt: '¿Qué componente representa este símbolo?',
    explanation: 'La flecha que toca el cuerpo del resistor es el cursor.',
    options: [
      AnswerOption('Resistor fijo',
          feedback: 'El resistor fijo no tiene tercer terminal.'),
      AnswerOption('Potenciómetro',
          correct: true,
          feedback: 'Correcto: el cursor divide la resistencia.'),
      AnswerOption('Inductor',
          feedback: 'El inductor se dibuja con espiras.'),
      AnswerOption('Fotorresistencia',
          feedback: 'La LDR tiene flechas de luz que llegan desde afuera.'),
    ],
  ),
];
