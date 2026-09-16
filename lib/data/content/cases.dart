import '../../domain/models/competency.dart';
import '../../domain/models/learning_module.dart';
import '../../domain/models/practical_case.dart';
import '../../domain/models/question.dart';

/// Módulo 5 — Aplicaciones reales.
const List<PracticalCase> practicalCases = [
  PracticalCase(
    id: 'night_light',
    title: 'Luz nocturna automática',
    difficulty: 1,
    context:
        'Una familia quiere que la luz del pasillo se encienda sola al '
        'anochecer. Dispones de una placa de 5 V, un LED blanco de alto '
        'brillo como prototipo y componentes básicos.',
    goal:
        'Elegir el sensor, dimensionar el LED y prever el error de '
        'realimentación óptica.',
    componentIds: ['ldr', 'led', 'bjt_npn', 'resistor'],
    steps: [
      Question(
        id: 'nl_sensor',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'ldr',
        prompt: '¿Qué sensor usarás para detectar el anochecer?',
        explanation: 'Solo se necesita un umbral de luz: la LDR es suficiente '
            'y la más económica.',
        options: [
          AnswerOption('LM35',
              feedback: 'Mide temperatura; al anochecer puede no cambiar lo suficiente.'),
          AnswerOption('LDR en un divisor de tensión',
              correct: true,
              feedback: 'Correcto: detecta el nivel de luz con un componente barato.'),
          AnswerOption('HC-SR04',
              feedback: 'Mide distancia, no luz.'),
          AnswerOption('NTC',
              feedback: 'Responde a la temperatura.'),
        ],
      ),
      Question(
        id: 'nl_resistor',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'led',
        prompt:
            'El LED de prueba es rojo (VF = 2 V) y debe trabajar con 15 mA a '
            '5 V. ¿Qué resistencia calculas? Responde en Ω.',
        explanation: 'R = (5 − 2) / 0.015 = 200 Ω; comercialmente, 220 Ω.',
        numeric: NumericSpec(
          simulationId: 'led_resistor',
          inputs: {'vcc': 5, 'color': 0, 'if': 15},
          outputKey: 'r_calc',
          unitLabel: 'Ω',
        ),
      ),
      Question(
        id: 'nl_driver',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'bjt_npn',
        prompt:
            'La versión final usará un módulo LED de 120 mA a 5 V, controlado '
            'por un pin que entrega como máximo 20 mA. ¿Cómo lo conectas?',
        explanation: 'El pin no puede entregar 120 mA; un BJT saturado '
            'amplifica la corriente con bajo costo.',
        options: [
          AnswerOption('Directamente al pin',
              feedback: 'Superaría seis veces la corriente del pin.'),
          AnswerOption('Con un BJT NPN saturado y resistor de base',
              correct: true,
              feedback: 'Correcto: con β ≥ 100, bastan unos pocos mA de base.'),
          AnswerOption('Con un potenciómetro en serie',
              feedback: 'El potenciómetro no amplifica corriente y se calentaría.'),
          AnswerOption('Con un capacitor electrolítico en serie',
              feedback: 'Bloquearía la corriente continua.'),
        ],
      ),
      Question(
        id: 'nl_feedback',
        module: ModuleId.applications,
        competency: Competency.functional,
        componentId: 'ldr',
        prompt:
            'Al probarlo, la luz parpadea sin parar al anochecer. ¿Cuál es la '
            'causa más probable?',
        explanation: 'La LDR ve la luz que ella misma enciende: se apaga, '
            'oscurece y vuelve a encender.',
        options: [
          AnswerOption('La LDR recibe la luz del LED que controla',
              correct: true,
              feedback: 'Correcto: aíslala ópticamente o agrega histéresis.'),
          AnswerOption('El LED está al revés',
              feedback: 'Si estuviera invertido no encendería nunca.'),
          AnswerOption('El resistor del LED es demasiado grande',
              feedback: 'Eso reduce el brillo, no provoca oscilación.'),
          AnswerOption('La fuente es de 5 V',
              feedback: 'La tensión es adecuada para este circuito.'),
        ],
      ),
    ],
    takeaways: [
      'Un sensor simple basta cuando solo se necesita un umbral.',
      'La corriente de un pin digital es limitada: usa un transistor como interfaz.',
      'Los sistemas que se observan a sí mismos necesitan histéresis.',
    ],
  ),
  PracticalCase(
    id: 'power_supply',
    title: 'Fuente de 5 V para un prototipo',
    difficulty: 2,
    context:
        'Un laboratorio necesita alimentar placas de desarrollo con 5 V y '
        '500 mA a partir de un transformador que entrega 12 V pico después '
        'de rectificar con un puente.',
    goal:
        'Elegir los diodos, dimensionar el filtro y prever el calor del '
        'regulador.',
    componentIds: [
      'diode_rectifier',
      'capacitor_electrolytic',
      'regulator_7805',
      'capacitor_ceramic',
    ],
    steps: [
      Question(
        id: 'ps_diodes',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'diode_rectifier',
        prompt: '¿Qué diodos usas para el puente rectificador?',
        explanation: 'El 1N4007 soporta 1 A y 1000 V: sobra margen para 500 mA '
            'y 12 V.',
        options: [
          AnswerOption('Cuatro 1N4007',
              correct: true,
              feedback: 'Correcto: corriente y tensión inversa con margen.'),
          AnswerOption('Cuatro Zener de 5.1 V',
              feedback: 'Conducirían en inversa a 5.1 V y el puente no funcionaría.'),
          AnswerOption('Cuatro LED rojos',
              feedback: 'Solo soportan unos 5 V en inversa y 20 mA.'),
          AnswerOption('Un solo 1N4007',
              feedback: 'Un diodo solo rectifica media onda; el caso pide un puente.'),
        ],
      ),
      Question(
        id: 'ps_ripple',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'capacitor_electrolytic',
        prompt:
            'Con 2200 µF y onda completa a 60 Hz, ¿qué rizado tendrás con '
            '500 mA? Responde en V.',
        explanation: 'ΔV = 0.5 / (120 · 0.0022) ≈ 1.89 V. La entrada mínima '
            'del regulador queda cerca de 10.1 V, por encima de los 7 V '
            'necesarios.',
        numeric: NumericSpec(
          simulationId: 'ripple_filter',
          inputs: {'vp': 12, 'iload': 500, 'c': 2200, 'mode': 1},
          outputKey: 'ripple',
          unitLabel: 'V',
        ),
      ),
      Question(
        id: 'ps_voltage_rating',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'capacitor_electrolytic',
        prompt: '¿Qué tensión nominal eliges para el capacitor de filtro?',
        explanation: '1.5 · 12 V = 18 V: el valor comercial siguiente es 25 V.',
        options: [
          AnswerOption('10 V',
              feedback: 'Menor que el pico de 12 V: fallaría.'),
          AnswerOption('16 V',
              feedback: 'Supera el pico, pero sin el margen del 50 % '
                  'recomendado frente a variaciones de la red.'),
          AnswerOption('25 V',
              correct: true,
              feedback: 'Correcto: margen suficiente para picos de la red.'),
          AnswerOption('Da igual, lo importante es la capacidad',
              feedback: 'Superar la tensión nominal destruye el capacitor.'),
        ],
      ),
      Question(
        id: 'ps_heat',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'regulator_7805',
        prompt:
            'El 7805 recibe unos 12 V y entrega 500 mA. ¿Cuánta potencia '
            'disipa? Responde en W.',
        explanation: 'P = (12 − 5) · 0.5 = 3.5 W. Sin disipador superaría la '
            'temperatura máxima: se requiere disipador.',
        numeric: NumericSpec(
          simulationId: 'regulator_7805',
          inputs: {'vin': 12, 'iload': 500},
          outputKey: 'p',
          unitLabel: 'W',
        ),
      ),
      Question(
        id: 'ps_decoupling',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'capacitor_ceramic',
        prompt:
            'El fabricante del 7805 recomienda capacitores junto a sus pines. '
            '¿Cuál colocas en la salida?',
        explanation: 'Un cerámico de 100 nF mejora la respuesta a transitorios '
            'rápidos y evita oscilaciones.',
        options: [
          AnswerOption('Cerámico de 100 nF',
              correct: true,
              feedback: 'Correcto: baja inductancia, junto al pin de salida.'),
          AnswerOption('Inductor de 10 mH',
              feedback: 'Un inductor en serie empeoraría la respuesta dinámica.'),
          AnswerOption('Resistor de 1 Ω',
              feedback: 'No almacena energía y desperdicia potencia.'),
          AnswerOption('Ninguno, el regulador es estable solo',
              feedback: 'Sin capacitores puede oscilar.'),
        ],
      ),
    ],
    takeaways: [
      'Cada etapa de una fuente tiene un componente que la define.',
      'La tensión nominal de un electrolítico necesita margen.',
      'Un regulador lineal convierte en calor toda la diferencia de tensión.',
    ],
  ),
  PracticalCase(
    id: 'fan_control',
    title: 'Ventilador controlado por microcontrolador',
    difficulty: 2,
    context:
        'Un tablero de control necesita encender un ventilador de 12 V y '
        '1 A desde una placa de 3.3 V cuando la temperatura sube.',
    goal:
        'Elegir el interruptor adecuado y proteger el circuito frente a la '
        'carga inductiva.',
    componentIds: ['mosfet_n', 'diode_rectifier', 'bjt_npn', 'inductor'],
    steps: [
      Question(
        id: 'fc_switch',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'mosfet_n',
        prompt: '¿Qué dispositivo conmuta mejor el ventilador de 1 A?',
        explanation: 'Con 1 A, un MOSFET de nivel lógico disipa muy poco y el '
            'pin de 3.3 V basta para encenderlo.',
        options: [
          AnswerOption('BC547',
              feedback: 'Su límite es 100 mA.'),
          AnswerOption('MOSFET de nivel lógico',
              correct: true,
              feedback: 'Correcto: conduce plenamente con 3.3 V.'),
          AnswerOption('LED de potencia',
              feedback: 'Un LED no conmuta cargas.'),
          AnswerOption('Potenciómetro de 10 kΩ',
              feedback: 'No soporta la potencia del ventilador.'),
        ],
      ),
      Question(
        id: 'fc_vth',
        module: ModuleId.applications,
        competency: Competency.functional,
        componentId: 'mosfet_n',
        prompt:
            'Con un MOSFET de Vth = 2 V y 3.3 V en la compuerta, ¿qué corriente '
            'deja pasar según el modelo del laboratorio (carga de 12 Ω a '
            '12 V)? Responde en A.',
        explanation: 'Con solo 1.3 V por encima del umbral, el MOSFET limita '
            'la corriente a ≈ 0.85 A y queda en conducción parcial: el '
            'ventilador no recibe su corriente y el MOSFET se calienta.',
        numeric: NumericSpec(
          simulationId: 'mosfet_switch',
          inputs: {'vgs': 3.3, 'vth': 2, 'vdd': 12, 'rl': 12},
          outputKey: 'id',
          unitLabel: 'A',
        ),
      ),
      Question(
        id: 'fc_flyback',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'diode_rectifier',
        prompt: '¿Cómo proteges el MOSFET cuando se apaga el motor del ventilador?',
        explanation: 'El motor es inductivo: un diodo en antiparalelo da '
            'camino a la corriente y evita la sobretensión.',
        options: [
          AnswerOption('Diodo en antiparalelo con el motor',
              correct: true,
              feedback: 'Correcto: es el diodo de rueda libre.'),
          AnswerOption('Resistor en serie con la compuerta',
              feedback: 'Limita picos de compuerta, pero no la sobretensión del motor.'),
          AnswerOption('LED en serie con el motor',
              feedback: 'Limitaría la corriente del motor a unos mA.'),
          AnswerOption('Nada, el MOSFET soporta cualquier tensión',
              feedback: 'Todo MOSFET tiene una VDS máxima.'),
        ],
      ),
      Question(
        id: 'fc_gate',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'mosfet_n',
        prompt:
            'Al reiniciar la placa, el ventilador arranca solo por un instante. '
            '¿Qué falta?',
        explanation: 'Durante el arranque el pin queda en alta impedancia; '
            'un resistor de compuerta a fuente mantiene el MOSFET apagado.',
        options: [
          AnswerOption('Un resistor de 10 kΩ a 100 kΩ entre compuerta y fuente',
              correct: true,
              feedback: 'Correcto: fija la compuerta en 0 V mientras el pin flota.'),
          AnswerOption('Un capacitor de 1000 µF en la compuerta',
              feedback: 'Retrasaría la conmutación y calentaría el MOSFET.'),
          AnswerOption('Un Zener en serie con el ventilador',
              feedback: 'Solo restaría tensión al ventilador.'),
          AnswerOption('Un potenciómetro en la alimentación',
              feedback: 'No resuelve la compuerta flotante.'),
        ],
      ),
    ],
    takeaways: [
      'Superar Vth no significa conducir plenamente: revisa RDS(on).',
      'Toda carga inductiva necesita diodo de rueda libre.',
      'Una compuerta flotante produce encendidos inesperados.',
    ],
  ),
  PracticalCase(
    id: 'thermometer',
    title: 'Termómetro con alarma',
    difficulty: 3,
    context:
        'Un cuarto de servidores necesita un termómetro que active una '
        'alarma sonora al superar 37 °C. El microcontrolador tiene un ADC '
        'de 10 bits con referencia de 5 V.',
    goal:
        'Elegir el sensor, acondicionar la señal y generar el tono de alarma.',
    componentIds: ['lm35', 'opamp', 'timer_555', 'ntc'],
    steps: [
      Question(
        id: 'th_sensor',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'lm35',
        prompt: '¿Qué sensor eliges si quieres una lectura directa sin calibración?',
        explanation: 'El LM35 es lineal y está calibrado; la placa es de 5 V.',
        options: [
          AnswerOption('LM35',
              correct: true,
              feedback: 'Correcto: 10 mV/°C sin tablas.'),
          AnswerOption('NTC',
              feedback: 'Sirve, pero necesitaría la ecuación Beta.'),
          AnswerOption('LDR',
              feedback: 'Mide luz.'),
          AnswerOption('Diodo Zener',
              feedback: 'No es un sensor de temperatura práctico.'),
        ],
      ),
      Question(
        id: 'th_vout',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'lm35',
        prompt: '¿Qué tensión entrega el LM35 en el umbral de 37 °C? Responde en mV.',
        explanation: '10 mV/°C · 37 °C = 370 mV.',
        numeric: NumericSpec(
          simulationId: 'lm35_adc',
          inputs: {'t': 37, 'vref': 0},
          outputKey: 'vout',
          unitLabel: 'mV',
          scale: 1e-3,
        ),
      ),
      Question(
        id: 'th_amp',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'opamp',
        prompt:
            'Para mejorar la resolución amplificas con un no inversor '
            '(Rf = 10 kΩ, Rin = 1 kΩ, ±12 V). ¿Qué tensión llega al ADC a '
            '37 °C? Responde en V.',
        explanation: 'G = 11: 0.37 V · 11 = 4.07 V, dentro del rango de 5 V '
            'del ADC. Por encima de 45 °C la señal superaría 5 V: revisa la '
            'ganancia según el rango que necesitas medir.',
        numeric: NumericSpec(
          simulationId: 'opamp_amplifier',
          inputs: {'mode': 1, 'vin': 0.37, 'rf': 10000, 'rin': 1000, 'vcc': 12},
          outputKey: 'vout',
          unitLabel: 'V',
        ),
      ),
      Question(
        id: 'th_tone',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'timer_555',
        prompt:
            'La alarma usa un 555 con R1 = 1 kΩ, R2 = 10 kΩ y C = 10 µF para '
            'un pitido intermitente. ¿Qué frecuencia genera? Responde en Hz.',
        explanation: 'f = 1 / (0.693 · 21 kΩ · 10 µF) ≈ 6.9 Hz: un pitido '
            'intermitente claramente perceptible.',
        numeric: NumericSpec(
          simulationId: 'timer555_astable',
          inputs: {'r1': 1000, 'r2': 10000, 'c': 10},
          outputKey: 'f',
          unitLabel: 'Hz',
        ),
      ),
    ],
    takeaways: [
      'Acondicionar la señal mejora la resolución, pero hay que cuidar el rango.',
      'Un sensor calibrado simplifica el programa.',
      'Un 555 resuelve la señal de alarma sin ocupar el microcontrolador.',
    ],
  ),
  PracticalCase(
    id: 'parking_sensor',
    title: 'Sensor de estacionamiento',
    difficulty: 2,
    context:
        'Un taller quiere un sensor que avise cuando un vehículo está a menos '
        'de 50 cm de la pared. El sistema trabaja con un microcontrolador de '
        '3.3 V y se instala en un local con temperaturas de 15 °C a 30 °C.',
    goal:
        'Calcular la señal del sensor, protegerlo eléctricamente y evaluar '
        'el error por temperatura.',
    componentIds: ['hcsr04', 'resistor', 'ntc'],
    steps: [
      Question(
        id: 'pk_echo',
        module: ModuleId.applications,
        competency: Competency.application,
        componentId: 'hcsr04',
        prompt:
            '¿Cuánto dura el eco cuando el vehículo está a 50 cm con aire a '
            '20 °C? Responde en ms.',
        explanation: 't = 2 · 0.5 / 343.4 ≈ 2.91 ms. El programa compara el '
            'eco con este umbral.',
        numeric: NumericSpec(
          simulationId: 'ultrasonic_tof',
          inputs: {'d': 50, 't': 20},
          outputKey: 'echo',
          unitLabel: 'ms',
          scale: 1e-3,
        ),
      ),
      Question(
        id: 'pk_level',
        module: ModuleId.applications,
        competency: Competency.selection,
        componentId: 'resistor',
        prompt: '¿Cómo conectas el pin ECHO de 5 V al microcontrolador de 3.3 V?',
        explanation: 'Un divisor, por ejemplo 1 kΩ y 2 kΩ, baja el pulso a '
            '≈ 3.3 V.',
        options: [
          AnswerOption('Con un divisor resistivo de 1 kΩ y 2 kΩ',
              correct: true,
              feedback: 'Correcto: 5 · 2/3 ≈ 3.3 V.'),
          AnswerOption('Directamente',
              feedback: '5 V pueden dañar la entrada.'),
          AnswerOption('Con un capacitor de 100 nF en serie',
              feedback: 'Deformaría el pulso y no fija el nivel de tensión.'),
          AnswerOption('Con un LED en serie',
              feedback: 'Restaría tensión de forma imprecisa y limitaría la señal.'),
        ],
      ),
      Question(
        id: 'pk_temp',
        module: ModuleId.applications,
        competency: Competency.functional,
        componentId: 'hcsr04',
        prompt:
            'Si el programa asume 343 m/s y el local está a 30 °C, ¿el sensor '
            'mide de más o de menos?',
        explanation: 'A 30 °C el sonido viaja más rápido (≈ 349.5 m/s): el eco '
            'llega antes y el programa calcula una distancia menor que la real.',
        options: [
          AnswerOption('De más',
              feedback: 'El eco llega antes, así que el cálculo da menos.'),
          AnswerOption('De menos',
              correct: true,
              feedback: 'Correcto: una NTC puede compensar la velocidad del sonido.'),
          AnswerOption('Igual, la temperatura no influye',
              feedback: 'La velocidad del sonido cambia unos 0.6 m/s por °C.'),
          AnswerOption('El sensor deja de funcionar',
              feedback: 'Funciona hasta temperaturas mucho mayores.'),
        ],
      ),
    ],
    takeaways: [
      'Los módulos de 5 V necesitan adaptar niveles en sistemas de 3.3 V.',
      'El tiempo de vuelo depende del medio: la temperatura introduce error.',
      'Un segundo sensor puede compensar la magnitud que afecta al primero.',
    ],
  ),
];
