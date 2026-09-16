import 'question.dart';

/// Caso profesional del módulo «Aplicaciones reales».
///
/// Cada caso es una secuencia de decisiones de diseño sobre un circuito
/// completo: elegir, dimensionar y anticipar fallas.
class PracticalCase {
  const PracticalCase({
    required this.id,
    required this.title,
    required this.context,
    required this.goal,
    required this.componentIds,
    required this.steps,
    required this.takeaways,
    required this.difficulty,
  });

  final String id;
  final String title;

  /// Situación realista que plantea la necesidad.
  final String context;

  /// Qué debe lograr el estudiante al terminar.
  final String goal;

  final List<String> componentIds;
  final List<Question> steps;

  /// Conclusiones que se muestran al cerrar el caso.
  final List<String> takeaways;

  /// 1 = básico, 2 = intermedio, 3 = avanzado.
  final int difficulty;
}
