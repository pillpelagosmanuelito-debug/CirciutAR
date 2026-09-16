import '../../domain/models/comparison.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';
import '../content/comparisons.dart';
import '../content/components_active.dart';
import '../content/components_passive.dart';
import '../content/components_semiconductors.dart';
import '../content/components_sensors.dart';
import '../content/modules.dart';

/// Acceso al catálogo de componentes y módulos.
///
/// La interfaz permite reemplazar el contenido local por uno remoto (por
/// ejemplo, un CMS docente) sin tocar la presentación.
abstract class ComponentRepository {
  List<LearningModule> modules();
  LearningModule module(ModuleId id);
  List<ElectronicComponent> all();
  List<ElectronicComponent> byCategory(ComponentCategory category);
  ElectronicComponent? findById(String id);
  List<ElectronicComponent> search(String query, {ComponentCategory? category});
  ComparisonView compare(String leftId, String rightId);
  List<CuratedComparison> curatedFor(String componentId);
}

class LocalComponentRepository implements ComponentRepository {
  const LocalComponentRepository();

  static const List<ElectronicComponent> _all = [
    ...passiveComponents,
    ...activeComponents,
    ...semiconductorComponents,
    ...sensorComponents,
  ];

  @override
  List<LearningModule> modules() => learningModules;

  @override
  LearningModule module(ModuleId id) =>
      learningModules.firstWhere((m) => m.id == id);

  @override
  List<ElectronicComponent> all() => _all;

  @override
  List<ElectronicComponent> byCategory(ComponentCategory category) =>
      _all.where((c) => c.category == category).toList();

  @override
  ElectronicComponent? findById(String id) {
    for (final c in _all) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  List<ElectronicComponent> search(
    String query, {
    ComponentCategory? category,
  }) {
    final q = normalize(query);
    return _all.where((c) {
      if (category != null && c.category != category) return false;
      if (q.isEmpty) return true;
      final haystack = normalize(
        '${c.name} ${c.shortName} ${c.summary} ${c.example ?? ''} '
        '${c.applications.join(' ')}',
      );
      return haystack.contains(q);
    }).toList();
  }

  @override
  ComparisonView compare(String leftId, String rightId) {
    final left = findById(leftId);
    final right = findById(rightId);
    if (left == null || right == null) {
      throw ArgumentError('Componente desconocido.');
    }
    final curated = curatedComparisons
        .where((c) => c.matches(leftId, rightId))
        .toList();

    final genericRows = [
      for (final key in TraitKeys.all)
        ComparisonRow(
          key,
          left.traits[key] ?? '—',
          right.traits[key] ?? '—',
        ),
    ];

    if (curated.isEmpty) {
      return ComparisonView(
        leftId: leftId,
        rightId: rightId,
        rows: genericRows,
      );
    }

    final c = curated.first;
    final straight = c.aId == leftId;
    final rows = [
      for (final r in c.rows)
        straight ? r : ComparisonRow(r.aspect, r.b, r.a),
      ...genericRows,
    ];
    return ComparisonView(
      leftId: leftId,
      rightId: rightId,
      rows: rows,
      keyDifference: c.keyDifference,
      chooseLeftWhen: straight ? c.chooseAWhen : c.chooseBWhen,
      chooseRightWhen: straight ? c.chooseBWhen : c.chooseAWhen,
    );
  }

  @override
  List<CuratedComparison> curatedFor(String componentId) => curatedComparisons
      .where((c) => c.aId == componentId || c.bId == componentId)
      .toList();

  /// Minúsculas y sin tildes: una búsqueda escrita sin tildes («ceramico»)
  /// encuentra el nombre correcto («Capacitor cerámico»).
  static String normalize(String input) {
    const from = 'áéíóúüñÁÉÍÓÚÜÑ';
    const to = 'aeiouunAEIOUUN';
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer.toString().toLowerCase().trim();
  }
}
