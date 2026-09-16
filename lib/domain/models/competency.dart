/// Competencias que la aplicación desarrolla y evalúa.
///
/// Cada pregunta, paso de caso y simulación se asocia con una de ellas para
/// que el progreso se mida por competencia y no solo por puntaje global.
enum Competency {
  identification(
    'Identificación de componentes',
    'Reconocer el componente por su símbolo, su encapsulado y sus marcas.',
  ),
  functional(
    'Comprensión funcional',
    'Explicar qué hace el componente y cómo responde ante cambios.',
  ),
  selection(
    'Selección adecuada',
    'Elegir el componente correcto y justificar por qué no los demás.',
  ),
  application(
    'Aplicación práctica',
    'Dimensionar y usar el componente dentro de un circuito real.',
  );

  const Competency(this.label, this.description);

  final String label;
  final String description;
}

/// Nivel de dominio calculado a partir de la tasa de acierto.
enum MasteryLevel {
  noEvidence('Sin evidencias'),
  developing('En desarrollo'),
  acceptable('Aceptable'),
  achieved('Logrado');

  const MasteryLevel(this.label);

  final String label;

  static MasteryLevel fromStats({required int attempts, required int correct}) {
    if (attempts <= 0) return MasteryLevel.noEvidence;
    final rate = correct / attempts;
    if (rate >= 0.8) return MasteryLevel.achieved;
    if (rate >= 0.5) return MasteryLevel.acceptable;
    return MasteryLevel.developing;
  }
}
