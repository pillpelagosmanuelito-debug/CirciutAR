/// Fila de una tabla comparativa.
class ComparisonRow {
  const ComparisonRow(this.aspect, this.a, this.b);

  final String aspect;
  final String a;
  final String b;
}

/// Comparación curada entre dos componentes que suelen confundirse.
class CuratedComparison {
  const CuratedComparison({
    required this.aId,
    required this.bId,
    required this.keyDifference,
    required this.chooseAWhen,
    required this.chooseBWhen,
    required this.rows,
  });

  final String aId;
  final String bId;

  /// La diferencia que decide la selección, en una frase.
  final String keyDifference;
  final String chooseAWhen;
  final String chooseBWhen;
  final List<ComparisonRow> rows;

  bool matches(String x, String y) =>
      (aId == x && bId == y) || (aId == y && bId == x);
}

/// Comparación lista para mostrar, orientada según el orden elegido.
class ComparisonView {
  const ComparisonView({
    required this.leftId,
    required this.rightId,
    required this.rows,
    this.keyDifference,
    this.chooseLeftWhen,
    this.chooseRightWhen,
  });

  final String leftId;
  final String rightId;
  final List<ComparisonRow> rows;
  final String? keyDifference;
  final String? chooseLeftWhen;
  final String? chooseRightWhen;

  bool get isCurated => keyDifference != null;
}
