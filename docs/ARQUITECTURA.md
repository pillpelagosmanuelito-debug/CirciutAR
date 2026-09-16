# Arquitectura técnica de CircuitAR

## 1. Stack

| Capa | Tecnología | Motivo |
|---|---|---|
| Interfaz | Flutter 3.24 · Material 3 | Una base de código; símbolos y gráficas con `CustomPainter` |
| Estado | Riverpod 2.5 (`Notifier`, `AutoDisposeFamilyNotifier`) | ViewModels comprobables sin widgets |
| Persistencia | `shared_preferences` | Progreso local; la app funciona sin conexión |
| Dominio | Dart puro | Simulaciones y evaluación sin dependencias de Flutter |
| CI/CD | GitHub Actions | Análisis, pruebas, APK y publicación por etiqueta |

No se usan librerías de gráficos ni de imágenes: todo se dibuja con vectores. Menos dependencias significa menos rupturas entre versiones de Flutter.

## 2. Capas (MVVM + Repository Pattern)

```
┌──────────────────────── Presentación (features/) ────────────────────────┐
│  Screen (ConsumerWidget) ──observa──▶ ViewModel (Notifier de Riverpod)    │
└────────────────────────────────────────────┬─────────────────────────────┘
                                             │ usa
┌──────────────────────── Datos (data/) ─────▼─────────────────────────────┐
│  ComponentRepository · LearningRepository · ProgressRepository (interfaces)│
│  Local*Repository ──lee──▶ content/*.dart (contenido declarativo)         │
└────────────────────────────────────────────┬─────────────────────────────┘
                                             │ devuelve modelos
┌──────────────────────── Dominio (domain/) ─▼─────────────────────────────┐
│  models/ · simulation/ (17 modelos cerrados) · services/AnswerEvaluator   │
└──────────────────────────────────────────────────────────────────────────┘
```

Reglas:

1. Las pantallas no contienen lógica de negocio: solo leen el estado y llaman métodos del ViewModel.
2. Los ViewModels no conocen el origen de los datos: dependen de interfaces de repositorio inyectadas por proveedores.
3. El dominio no importa Flutter (salvo `formatters.dart`, que es Dart puro dentro de `core/`).
4. Todo proveedor puede sobrescribirse en pruebas (`ProviderContainer(overrides: …)`).

## 3. Estructura de carpetas

```
lib/
├── main.dart                 # Inicializa SharedPreferences y ProviderScope
├── app.dart                  # MaterialApp y temas claro/oscuro
├── core/
│   ├── theme/                # Colores por módulo y por nivel de mensaje
│   ├── utils/formatters.dart # Prefijos de ingeniería y lectura de números
│   └── widgets/              # Símbolos, resistor, gráfica y componentes comunes
├── domain/
│   ├── models/               # Componente, pregunta, caso, progreso, asistente…
│   ├── simulation/           # Modelos por familia, registro, código de colores, serie E12
│   └── services/             # Evaluador de respuestas
├── data/
│   ├── content/              # Fichas, preguntas, casos, comparaciones, árbol del asistente
│   └── repositories/         # Interfaces e implementaciones locales
├── providers/providers.dart  # Inyección de dependencias y ProgressNotifier
└── features/                 # Una carpeta por funcionalidad (pantalla + ViewModel)
    ├── home/  catalog/  simulation/  identification/  comparison/
    ├── cases/  assessment/  assistant/  progress/  shell/
```

## 4. ViewModels

| ViewModel | Tipo | Estado | Responsabilidad |
|---|---|---|---|
| `ProgressNotifier` | `Notifier` global | `LearningProgress` | Registro y persistencia del progreso |
| `CatalogViewModel` | `Notifier` | búsqueda y filtro | Búsqueda sin tildes por categoría |
| `SimulationViewModel` | `AutoDisposeFamilyNotifier<…, String>` | parámetros y resultado | Recalcular al instante, limitar valores |
| `ComparisonViewModel` | familia con registro `(left, right)` | par elegido y vista | Pareja por defecto, intercambio |
| `QuizViewModel` | familia por `quizId` | índice y resultados | Flujo de evaluación, puntaje, competencias |
| `CaseViewModel` | familia por `caseId` | etapa y resultados | Introducción → decisiones → cierre |
| `AssistantViewModel` | `AutoDisposeNotifier` | nodo e historial | Recorrer el árbol y retroceder |
| `ColorCodeViewModel` | `AutoDisposeNotifier` | bandas | Validar colores por posición |

## 5. Motor de simulación

Cada componente tiene una `ComponentSimulation` con:

- `parameters`: lista de `SimParameter` (lineales, logarítmicos o discretos).
- `evaluate(inputs)`: función pura que devuelve `SimResult` con salidas en SI, estado o región, mensajes didácticos y curva opcional.
- `assumptions`: el modelo declarado, visible para el estudiante.

| Familia | Modelos |
|---|---|
| Pasivos | Ley de Ohm y potencia; divisor con carga; carga RC; rizado `ΔV = I/(f·C)` con red de 60 Hz; corriente RL |
| Semiconductores | Shockley resuelto por bisección; Zener ideal con límites; LED con serie E12; BJT por regiones; MOSFET cuadrático con RDS(on) |
| Activos | Amplificador ideal con saturación; 7805 con dropout y estimación térmica; 555 astable |
| Sensores | LDR potencial; NTC con ecuación Beta; LM35 con ADC de 10 bits; tiempo de vuelo con temperatura |

Los valores de las pruebas se calibraron con una implementación independiente en Python (`tools/reference_values.py`).

## 6. Evaluación sin respuestas escritas

`NumericSpec` indica la simulación, las entradas, la salida y la unidad pedida. `AnswerEvaluator.expectedValue()` ejecuta la simulación y compara con tolerancia relativa (2 % por defecto). Si el valor coincide salvo por un factor de mil o de un millón, la retroalimentación señala un error de unidades.

## 7. Persistencia

`LearningProgress` se serializa como JSON en la clave `circuitar.progress.v1`. Un dato corrupto no bloquea el arranque: se descarta y la app abre con progreso vacío. La interfaz `ProgressRepository` permite migrar a un servidor sin tocar los ViewModels.

## 8. Calidad

| Verificación | Dónde |
|---|---|
| Análisis estático (`flutter_lints` con `strict-casts` y `strict-raw-types`) | CI |
| Pruebas de dominio, repositorios, ViewModels y widgets | `test/` |
| Integridad del contenido (fichas completas, una respuesta correcta, árbol sin ciclos) | `test/data/content_integrity_test.dart` |
| Ortografía: 47 palabras que deben llevar tilde | misma prueba |
| Imports resueltos e identificadores ASCII | `tools/check_imports.py` |

## 9. CI/CD

`.github/workflows/ci.yml`:

1. Instala Java 17 y Flutter 3.24.5 (versión fijada).
2. Genera la carpeta `android/` con `flutter create --platforms=android` y ajusta el nombre visible a «CircuitAR».
3. Ejecuta la verificación de imports, `flutter analyze` y `flutter test --coverage`.
4. Compila `flutter build apk --release` y publica el APK como artefacto.
5. Si el commit tiene una etiqueta `v*`, crea una versión en GitHub con el APK adjunto.

Las carpetas de plataforma no se versionan para evitar desajustes con la plantilla de Flutter. Para firmar con una llave propia, agrega `android/key.properties` en un paso del flujo usando secretos del repositorio.

## 10. Cómo extender

**Agregar un componente:** crea la ficha en `data/content/components_*.dart`, añade su `SymbolType` y su dibujo en `symbol_painter.dart`, implementa su simulación y regístrala en `SimulationRegistry`, y agrega una rama en el árbol del asistente. Las pruebas de integridad indicarán lo que falte.

**Agregar una pregunta numérica:** declara un `NumericSpec` sin escribir la respuesta y añade el valor esperado a la prueba de contenido.
