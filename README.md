# CircuitAR

**Laboratorio móvil para aprender a identificar, comprender, seleccionar y aplicar componentes electrónicos.**

Aplicación del proyecto *Educational Mobile Apps Factory* para Ingeniería Electrónica, Mecatrónica y Automatización (cursos de Electrónica básica, Dispositivos electrónicos y Circuitos).

> El estudiante no memoriza el componente: aprende **cuándo y por qué usarlo**.

---

## Qué incluye la versión 1.0

| Módulo | Contenido |
|---|---|
| 1. Componentes pasivos | Resistor, potenciómetro, capacitor cerámico, capacitor electrolítico, inductor |
| 2. Componentes activos | Amplificador operacional, regulador 7805, temporizador 555 |
| 3. Semiconductores | Diodo rectificador, Zener, LED, BJT NPN, MOSFET de canal N |
| 4. Sensores | LDR, termistor NTC, LM35, HC-SR04 |
| 5. Aplicaciones reales | 5 casos de diseño con 20 decisiones |
| 6. Evaluaciones | 6 evaluaciones (33 preguntas) y 2 prácticas generadas |

**Funcionalidades**

- **Fichas interactivas** en cuatro pestañas: funcionamiento, características, aplicaciones (con criterios «úsalo cuando / evítalo cuando») y errores comunes.
- **17 simulaciones** con resultados al instante, gráfica, región de operación y advertencias didácticas.
- **Comparador** lado a lado con 7 pares curados y criterio de selección.
- **Identificación visual**: lector del código de colores (4 y 5 bandas), galería de símbolos y prácticas generadas.
- **Asistente de selección** basado en reglas revisables (sin IA).
- **Progreso por competencia** con repaso recomendado según los errores.
- Funciona **sin conexión**; tema claro y oscuro.

Fuera del alcance de esta versión: reconocimiento con cámara, realidad aumentada e IA generativa. La justificación está en [`docs/ANALISIS_Y_DECISIONES.md`](docs/ANALISIS_Y_DECISIONES.md).

---

## Arquitectura

Flutter · Dart · Riverpod · MVVM · Repository Pattern · `shared_preferences`.

```
lib/
├── core/          tema, formato de magnitudes, widgets de dibujo
├── domain/        modelos, 17 simulaciones, evaluador de respuestas
├── data/          contenido declarativo y repositorios
├── providers/     inyección de dependencias y progreso
└── features/      pantallas y ViewModels por funcionalidad
```

Detalle en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

---

## Requisitos

- Flutter 3.24.5 (canal estable) · Dart 3.5
- Java 17 y Android SDK para compilar el APK

## Puesta en marcha local

```bash
# 1. Generar la carpeta android/ (no se versiona)
flutter create --platforms=android --org pe.edu.circuitar --project-name circuitar .

# 2. Dependencias
flutter pub get

# 3. Calidad
python3 tools/check_imports.py
flutter analyze
flutter test

# 4. Ejecutar o compilar
flutter run
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

> `flutter create` no sobrescribe archivos existentes: conserva `lib/`, `test/`, `pubspec.yaml` y este README.

---

## Subir a GitHub y obtener el APK

```bash
git init
git add .
git commit -m "CircuitAR 1.0"
git branch -M main
git remote add origin https://github.com/<usuario>/circuitar.git
git push -u origin main
```

El flujo `.github/workflows/ci.yml` se ejecuta en cada *push*:

1. Genera la plataforma Android con la versión fijada de Flutter.
2. Verifica imports, ejecuta el análisis estático y las pruebas.
3. Compila el APK y lo publica en la pestaña **Actions → artefacto `circuitar-apk`**.

Para publicar una versión con el APK adjunto:

```bash
git tag v1.0.0
git push origin v1.0.0
```

---

## Pruebas

| Archivo | Cubre |
|---|---|
| `test/domain/simulations_test.dart` | Las 17 simulaciones con valores calibrados |
| `test/domain/utilities_test.dart` | Serie E12, código de colores, formato, progreso |
| `test/data/content_integrity_test.dart` | Fichas completas, preguntas, árbol del asistente y **ortografía** |
| `test/data/repositories_test.dart` | Búsqueda, comparación, prácticas generadas, evaluador, persistencia |
| `test/features/view_models_test.dart` | Todos los ViewModels |
| `test/widget_test.dart` | Navegación, fichas, simulaciones, símbolos y evaluación |

Los valores esperados se calcularon con una implementación independiente: `python3 tools/reference_values.py`.

---

## Documentación

- [`docs/ANALISIS_Y_DECISIONES.md`](docs/ANALISIS_Y_DECISIONES.md) — diagnóstico crítico, riesgos, evaluación de IA y ruta de evolución.
- [`docs/DISENO_EDUCATIVO.md`](docs/DISENO_EDUCATIVO.md) — competencias, ruta de aprendizaje y casos.
- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — capas, ViewModels, motor y CI/CD.
- [`docs/GUIA_DOCENTE.md`](docs/GUIA_DOCENTE.md) — uso en clase y validación del contenido.
- [`CHANGELOG.md`](CHANGELOG.md) — historial de versiones.

---

*Educational Mobile Apps Factory · Ingeniería Electrónica*
