/// Los seis módulos de la aplicación.
enum ModuleId {
  passive,
  active,
  semiconductors,
  sensors,
  applications,
  assessments,
}

/// Categoría física de un componente. Los módulos 1 a 4 se corresponden con
/// una categoría; los módulos 5 y 6 son transversales.
enum ComponentCategory {
  passive('Pasivo', ModuleId.passive),
  active('Activo', ModuleId.active),
  semiconductor('Semiconductor', ModuleId.semiconductors),
  sensor('Sensor', ModuleId.sensors);

  const ComponentCategory(this.label, this.module);

  final String label;
  final ModuleId module;
}

class LearningModule {
  const LearningModule({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.objectives,
    this.category,
  });

  final ModuleId id;
  final int number;
  final String title;
  final String subtitle;
  final String description;
  final List<String> objectives;

  /// Categoría de componentes que agrupa, si el módulo es de catálogo.
  final ComponentCategory? category;

  bool get isCatalogModule => category != null;
}
