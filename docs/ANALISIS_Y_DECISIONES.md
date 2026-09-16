# CircuitAR — Análisis crítico y decisiones de producto

**Área:** Ingeniería Electrónica · **Usuarios:** Electrónica, Mecatrónica y Automatización · **Cursos:** Electrónica básica, Dispositivos electrónicos, Circuitos · **Versión analizada:** 1.0

El análisis no reemplaza la construcción: cada hallazgo se tradujo en una decisión aplicada en el código, indicada como **Decisión** en cada sección.

---

## 1. Diagnóstico del problema educativo

El enunciado identifica bien el síntoma: el estudiante **memoriza símbolos y valores, pero no sabe cuándo ni por qué usar cada componente**. El riesgo es construir una app que agrave el síntoma: un catálogo bonito es otra forma de memorizar.

**Prueba de sustitución.** Si la app solo muestra fichas, una hoja de datos o Wikipedia la reemplazan sin pérdida. La app solo se justifica si hace algo que el texto no hace:

| Necesidad real | ¿Lo resuelve un texto? | Respuesta de CircuitAR |
|---|---|---|
| Ver cómo responde un componente al cambiar un valor | No | 17 simulaciones con resultado inmediato |
| Decidir entre dos componentes parecidos | Parcialmente | Comparador con **criterio de selección** explícito |
| Equivocarse sin costo y entender por qué | No | Cada distractor tiene su propia explicación |
| Dimensionar (potencia, resistor, disipador) | No con retroalimentación | Preguntas numéricas calculadas por el simulador |
| Reconocer el componente en un esquema | Parcialmente | Símbolos vectoriales y práctica generada |

**Conclusión:** el núcleo pedagógico es la **selección justificada**. Todo lo demás (fichas, símbolos) es soporte.

---

## 2. Evaluación según los criterios del proyecto

| Criterio | Evaluación | Riesgo detectado |
|---|---|---|
| 1. Valor educativo | Alto si se centra en la selección | Bajo si se queda en catálogo |
| 2. Problema real | Sí: brecha entre teoría y uso | — |
| 3. Usuario objetivo | 2.º a 5.º ciclo de Electrónica, Mecatrónica y Automatización | Mecatrónica necesita más sensores y actuadores (ver §7) |
| 4. Competencias | Identificación, comprensión, selección y aplicación | Sin medición por competencia, no hay evidencia de logro |
| 5. Experiencia | Laboratorio + casos + evaluación | Riesgo de dispersión en muchas pantallas |
| 6. Viabilidad técnica | Alta: modelos cerrados en Dart puro | Ninguno relevante |
| 7. Diferenciación | Frente a hojas de datos: interacción; frente a SPICE: lenguaje del curso y criterio de selección | Solapamiento con CircuitLab Academy (§3) |
| 8. Potencial de uso | Alto, funciona sin conexión | Depende de la validación docente del contenido |

---

## 3. Debilidades y riesgos del planteamiento original

### 3.1 El nombre promete realidad aumentada que el MVP no incluye

«CircuitAR» sugiere cámara y AR, pero el propio encargo excluye el reconocimiento visual avanzado. Un estudiante que descarga la app esperando apuntar la cámara a una placa se sentirá engañado.

**Decisión:** se conserva el nombre como marca, con el subtítulo «Laboratorio de componentes electrónicos», y la pantalla de identificación declara que el reconocimiento con cámara no forma parte de esta versión. La AR queda condicionada a un caso de uso que la justifique (§6).

### 3.2 Solapamiento con CircuitLab Academy (aplicación 34)

Ambas apps son de Electrónica y comparten el curso de Electrónica básica. Construir un segundo simulador de circuitos duplicaría esfuerzo y confundiría al usuario.

**Decisión:** separación explícita de propósito.

| | CircuitLab Academy | CircuitAR |
|---|---|---|
| Pregunta que responde | ¿Cómo se comporta **este circuito**? | ¿Qué **componente** uso y por qué? |
| Motor | MNA general con Newton-Raphson | Modelos cerrados por componente |
| Unidad de aprendizaje | Circuito completo | Componente en su circuito típico |

Se reutilizó el mismo modelo de diodo (Shockley, Is = 10 fA): el diodo con 5 V y 1 kΩ da **0.6925 V y 4.3075 mA** en ambas apps. Una prueba lo verifica.

### 3.3 Un catálogo sin criterio de selección no resuelve el problema

**Decisión:** cada ficha incluye «Úsalo cuando…» y «Evítalo cuando…», con la alternativa correcta. El comparador muestra «Elige X cuando…». Las preguntas de selección explican por qué cada distractor es incorrecto.

### 3.4 «Simulaciones simples» puede derivar en simulaciones triviales

**Decisión:** cada simulación tiene un objetivo de descubrimiento y está diseñada para que el estudiante **provoque el error típico**: quemar un resistor por potencia, cargar un divisor, dejar un BJT en zona activa, encender a medias un MOSFET con 3.3 V, saturar un amplificador, calentar un 7805.

### 3.5 Evaluaciones con respuestas fijas se desactualizan

**Decisión (patrón heredado de CircuitLab Academy):** las preguntas numéricas no guardan la respuesta; la calcula el mismo simulador. Si alguien cambia un modelo, las pruebas de contenido fallan en CI.

### 3.6 Sin medición por competencia no hay evidencia

**Decisión:** cada pregunta y cada decisión de caso se etiqueta con una de las cuatro competencias; el progreso muestra el nivel por competencia y recomienda repasar los componentes con más errores.

### 3.7 Ortografía y tildes

Una app universitaria con faltas pierde credibilidad. **Decisión:** una prueba automática revisa 47 palabras técnicas que deben llevar tilde en todas las cadenas de la interfaz; si falta una, CI falla. Los identificadores de código son ASCII y lo verifica `tools/check_imports.py`.

---

## 4. Alcance del MVP

### Incluido

| Módulo | Contenido |
|---|---|
| 1. Pasivos | Resistor, potenciómetro, capacitor cerámico, capacitor electrolítico, inductor |
| 2. Activos | Amplificador operacional, regulador 7805, temporizador 555 |
| 3. Semiconductores | Diodo rectificador, Zener, LED, BJT NPN, MOSFET de canal N |
| 4. Sensores | LDR, NTC, LM35, HC-SR04 |
| 5. Aplicaciones reales | 5 casos, 20 decisiones |
| 6. Evaluaciones | 5 evaluaciones temáticas + 1 integral; 33 preguntas en el banco, más prácticas generadas |

Funcionalidades: fichas en 4 pestañas (funcionamiento, características, aplicaciones, errores comunes), 17 simulaciones, comparador con 7 pares curados, identificación visual (código de colores, galería y dos prácticas generadas), asistente de selección, progreso por competencia.

### Excluido de forma deliberada

| Excluido | Motivo |
|---|---|
| Reconocimiento visual con cámara | Excluido por el encargo; alto costo y bajo valor frente a la práctica de lectura |
| Realidad aumentada | No hay aún un caso de uso que lo justifique (§6) |
| IA generativa | Ver §5 |
| Cuentas de usuario y servidor | El MVP funciona sin conexión; el progreso es local |
| Transistor PNP, MOSFET de canal P, relés, optoacopladores | Segunda iteración del catálogo |

---

## 5. Evaluación de la inteligencia artificial

| Uso propuesto | ¿Aporta valor que no dan las reglas? | Decisión |
|---|---|---|
| Recomendación de componentes | **No.** El universo de necesidades del curso es finito y las reglas son verificables por un docente | **Implementado sin IA**: árbol de decisión determinista con justificación y lista de verificación |
| Explicación personalizada | **Parcialmente.** La personalización útil (qué repasar) se deduce de los errores | **Implementado sin IA**: repaso recomendado según errores por componente |
| Asistente electrónico conversacional | **Sí**, para preguntas abiertas que el contenido no anticipa | **Versión 2**, con condiciones |

**Por qué no en el MVP.** Una explicación eléctrica equivocada enseña física falsa y el estudiante no tiene cómo detectarlo. Cambiar una respuesta siempre correcta por una casi siempre correcta, a cambio de costo por consulta, latencia y dependencia de conexión, es un mal negocio en esta etapa.

**Condiciones para la versión 2:**

1. El modelo propone y los simuladores deterministas validan cualquier valor numérico.
2. El asistente responde con referencia a las fichas de la app (recuperación sobre contenido validado).
3. Registro de preguntas sin respuesta para mejorar el contenido.
4. Métrica de éxito: reducción de errores repetidos, no minutos de uso.

---

## 6. ¿Cuándo tendría sentido la AR?

Solo si resuelve algo que la versión actual no resuelve. Candidato válido: **identificar el orden de terminales y el valor de un componente real sobre la protoboard** (por ejemplo, un TO-92 que puede ser 2N2222, BC547 o LM35). Condiciones para evaluarlo: evidencia de que los errores de montaje son frecuentes en el laboratorio y un piloto con cámara que muestre mejora frente a la galería de símbolos.

---

## 7. Riesgos que quedan abiertos

| Riesgo | Impacto | Mitigación propuesta |
|---|---|---|
| Contenido no validado por un docente | Alto | Revisión con la guía docente antes del piloto |
| Modelos simplificados confundidos con hojas de datos | Medio | Cada simulación declara su modelo y supuestos |
| Mecatrónica y Automatización piden más actuadores | Medio | Versión 1.1: relé, optoacoplador, puente H y motor DC |
| Progreso solo local | Bajo en el MVP | Exportación o sincronización en la versión 2 |
| Primera compilación ocurre en CI | Medio | Flujo de CI con análisis, 100+ pruebas y APK como artefacto |

---

## 8. Ruta de evolución

| Versión | Contenido |
|---|---|
| **1.0** | Este MVP |
| 1.1 | Relé, optoacoplador, PNP, MOSFET P, puente H; 3 casos de Mecatrónica |
| 1.2 | Modo docente: exportar resultados por competencia (CSV) |
| 2.0 | Asistente conversacional con validación determinista |
| 3.0 | Identificación con cámara, solo si el piloto de §6 lo justifica |

---

## 9. Indicadores para el piloto

- Tasa de acierto al primer intento en preguntas de **selección** (competencia central).
- Reducción de errores repetidos por componente entre la primera y la segunda evaluación.
- Porcentaje de estudiantes que usan la simulación antes de responder una pregunta numérica.
- Errores de montaje reportados en el laboratorio presencial antes y después del uso.
