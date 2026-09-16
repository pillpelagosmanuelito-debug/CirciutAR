# Guía docente de CircuitAR

## 1. Para qué usarla en clase

CircuitAR complementa las sesiones de Electrónica básica, Dispositivos electrónicos y Circuitos. Sirve para que el estudiante llegue al laboratorio sabiendo **qué componente usar y por qué**, y para detectar errores de selección antes de que ocurran con componentes reales.

## 2. Secuencia sugerida por semana

| Semana | Tema del curso | Actividad en CircuitAR |
|---|---|---|
| 1–2 | Resistencia, potencia, divisores | Módulo 1: resistor y potenciómetro; simulación de potencia |
| 3 | Capacitores e inductores | Módulo 1: cerámico, electrolítico, inductor; comparador |
| 4–5 | Diodos | Módulo 3: diodo, Zener, LED; caso «Fuente de 5 V» |
| 6–7 | Transistores | Módulo 3: BJT y MOSFET; caso «Ventilador controlado» |
| 8 | Evaluación parcial | Evaluaciones de pasivos y semiconductores |
| 9–10 | Amplificador operacional y reguladores | Módulo 2; simulaciones de saturación y calor |
| 11–12 | Sensores y acondicionamiento | Módulo 4; casos «Termómetro» y «Estacionamiento» |
| 13 | Integración | Caso «Luz nocturna» y evaluación integral |

## 3. Cómo usar los resultados

La pantalla **Progreso** muestra el nivel por competencia. Pida a los estudiantes una captura antes de cada práctica presencial:

- *Selección* en «En desarrollo»: repasar el comparador antes de armar.
- *Aplicación* baja: resolver en clase las preguntas numéricas y discutir la unidad pedida.
- *Repaso recomendado*: indica los componentes con más errores pendientes.

## 4. Preguntas para discutir después de cada simulación

- ¿Qué valor provocó la advertencia y por qué?
- ¿Qué componente alternativo evitaría el problema?
- ¿Qué supuesto del modelo no se cumple en el laboratorio real?

## 5. Validación del contenido

Antes de un piloto, un docente debe revisar:

1. Los valores típicos de las fichas frente a los componentes que compra el laboratorio.
2. Las 33 preguntas del banco y las 20 decisiones de los casos.
3. Las recomendaciones del asistente de selección.

Los cambios de contenido se hacen en `lib/data/content/`. Las pruebas automáticas avisan si una pregunta queda sin respuesta correcta, si una ficha queda incompleta o si falta una tilde en una palabra técnica frecuente.

## 6. Limitaciones que conviene explicar a los estudiantes

- Las simulaciones usan modelos simplificados declarados en cada pantalla.
- El progreso se guarda solo en el teléfono.
- La app no reconoce componentes con la cámara.
