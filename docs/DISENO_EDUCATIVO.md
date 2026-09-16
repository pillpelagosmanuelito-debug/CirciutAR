# Diseño educativo de CircuitAR

## 1. Competencias y evidencias

| Competencia | Qué hace el estudiante | Evidencia en la app |
|---|---|---|
| **Identificación** | Reconoce símbolo, encapsulado y marcas | Preguntas de símbolos, práctica generada, código de colores |
| **Comprensión funcional** | Explica cómo responde el componente | Simulaciones, preguntas de comportamiento |
| **Selección adecuada** | Elige y justifica frente a alternativas | Preguntas de selección, comparador, decisiones de casos |
| **Aplicación práctica** | Dimensiona dentro de un circuito real | Preguntas numéricas y casos de diseño |

Cada respuesta suma evidencia a una competencia. Niveles: *Sin evidencias*, *En desarrollo* (< 50 %), *Aceptable* (50–79 %) y *Logrado* (≥ 80 %).

## 2. Ruta de aprendizaje por componente

1. **Explora** — ficha en cuatro pestañas: funcionamiento, características, aplicaciones y errores comunes.
2. **Experimenta** — simulación con preguntas guía que llevan a provocar el error típico.
3. **Compara** — con el componente con el que suele confundirse; el comparador indica cuándo elegir cada uno.
4. **Aplica** — casos reales con decisiones encadenadas.
5. **Evalúate** — evaluación por módulo o integral, con repaso recomendado.

## 3. Principios

| Principio | Aplicación |
|---|---|
| El error enseña | Cada opción incorrecta tiene su propia explicación, no solo «incorrecto» |
| La selección se justifica | Fichas con «Úsalo cuando» y «Evítalo cuando»; el asistente explica su recomendación |
| El modelo es explícito | Cada simulación muestra sus supuestos; nada se presenta como hoja de datos |
| Contexto peruano | Red de 60 Hz en el filtro de rizado; componentes disponibles en el mercado local |
| Sin gamificación decorativa | No hay puntos ni medallas: el progreso muestra dominio por competencia |
| Accesibilidad | Símbolos con descripción semántica; bandas de color nombradas en texto para quienes no distinguen colores |

## 4. Simulaciones y descubrimiento esperado

| Simulación | El estudiante descubre que… |
|---|---|
| Resistor: corriente y potencia | el valor en ohmios no basta; la potencia nominal decide |
| Potenciómetro | una carga baja altera el divisor |
| Carga RC | en 1 τ se alcanza el 63 % y en 5 τ se considera completo |
| Filtro de rizado | la onda completa y la capacidad reducen el rizado; la tensión nominal necesita margen |
| Corriente RL | el inductor genera sobretensión al cortar la corriente |
| Diodo | la tensión en directa cambia poco aunque la corriente cambie mucho |
| Zener | existen dos límites: corriente mínima y potencia máxima |
| LED | se redondea al valor comercial superior y la tensión directa depende del color |
| BJT | Rb grande deja al transistor en zona activa y lo calienta |
| MOSFET | superar Vth no basta para conducir plenamente |
| Amplificador operacional | la salida no supera la alimentación |
| 7805 | la diferencia de tensión se convierte en calor |
| 555 | el ciclo de trabajo básico siempre supera el 50 % |
| LDR | el resistor fijo define la sensibilidad |
| NTC | la respuesta no es lineal |
| LM35 | la resolución del ADC limita la medición |
| HC-SR04 | la temperatura cambia la velocidad del sonido |

## 5. Casos prácticos

| Caso | Nivel | Componentes | Decisiones |
|---|---|---|---|
| Luz nocturna automática | Básico | LDR, LED, BJT, resistor | 4 |
| Fuente de 5 V | Intermedio | Diodos, electrolítico, 7805, cerámico | 5 |
| Ventilador controlado | Intermedio | MOSFET, diodo, BJT, inductor | 4 |
| Termómetro con alarma | Avanzado | LM35, amplificador, 555, NTC | 4 |
| Sensor de estacionamiento | Intermedio | HC-SR04, resistor, NTC | 3 |

## 6. Límites pedagógicos declarados

- Los modelos son simplificados; no sustituyen la hoja de datos ni el laboratorio presencial.
- No se enseña análisis de circuitos completos: para eso existe CircuitLab Academy.
- El catálogo cubre los componentes más frecuentes del temario introductorio; relés, optoacopladores y transistores PNP llegan en la versión 1.1.
