/// Recomendación del asistente de selección.
class Recommendation {
  const Recommendation({
    required this.componentId,
    required this.reason,
    required this.checks,
    this.alternativeId,
    this.alternativeNote,
  });

  final String componentId;

  /// Por qué este componente resuelve la necesidad.
  final String reason;

  /// Qué verificar en la hoja de datos antes de comprarlo.
  final List<String> checks;

  final String? alternativeId;
  final String? alternativeNote;
}

class AssistantOption {
  const AssistantOption(this.label, {this.nextId, this.recommendation})
      : assert(
          (nextId == null) != (recommendation == null),
          'Cada opción lleva a otra pregunta o a una recomendación.',
        );

  final String label;
  final String? nextId;
  final Recommendation? recommendation;
}

/// Nodo del árbol de decisión del asistente.
class AssistantNode {
  const AssistantNode({
    required this.id,
    required this.question,
    required this.options,
    this.hint,
  });

  final String id;
  final String question;
  final String? hint;
  final List<AssistantOption> options;
}
