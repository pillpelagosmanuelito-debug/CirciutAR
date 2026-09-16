import 'competency.dart';

class CompetencyStat {
  const CompetencyStat({this.attempts = 0, this.correct = 0});

  final int attempts;
  final int correct;

  double get rate => attempts == 0 ? 0 : correct / attempts;

  MasteryLevel get level =>
      MasteryLevel.fromStats(attempts: attempts, correct: correct);

  CompetencyStat add({required bool isCorrect}) => CompetencyStat(
        attempts: attempts + 1,
        correct: correct + (isCorrect ? 1 : 0),
      );

  Map<String, Object?> toJson() => {'a': attempts, 'c': correct};

  factory CompetencyStat.fromJson(Map<String, Object?> json) => CompetencyStat(
        attempts: (json['a'] as num?)?.toInt() ?? 0,
        correct: (json['c'] as num?)?.toInt() ?? 0,
      );
}

/// Progreso del estudiante, almacenado localmente.
class LearningProgress {
  const LearningProgress({
    this.viewedComponents = const {},
    this.usedSimulations = const {},
    this.completedCases = const {},
    this.bestScores = const {},
    this.competencies = const {},
    this.mistakesByComponent = const {},
  });

  final Set<String> viewedComponents;
  final Set<String> usedSimulations;
  final Set<String> completedCases;

  /// Mejor porcentaje por evaluación.
  final Map<String, int> bestScores;

  final Map<Competency, CompetencyStat> competencies;

  /// Respuestas incorrectas acumuladas por componente.
  final Map<String, int> mistakesByComponent;

  static const empty = LearningProgress();

  CompetencyStat statFor(Competency c) =>
      competencies[c] ?? const CompetencyStat();

  int get totalAttempts =>
      competencies.values.fold(0, (sum, s) => sum + s.attempts);

  /// Componentes con más errores, para recomendar repaso.
  List<String> reviewSuggestions({int limit = 3}) {
    final entries = mistakesByComponent.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((e) => e.key).toList();
  }

  LearningProgress copyWith({
    Set<String>? viewedComponents,
    Set<String>? usedSimulations,
    Set<String>? completedCases,
    Map<String, int>? bestScores,
    Map<Competency, CompetencyStat>? competencies,
    Map<String, int>? mistakesByComponent,
  }) =>
      LearningProgress(
        viewedComponents: viewedComponents ?? this.viewedComponents,
        usedSimulations: usedSimulations ?? this.usedSimulations,
        completedCases: completedCases ?? this.completedCases,
        bestScores: bestScores ?? this.bestScores,
        competencies: competencies ?? this.competencies,
        mistakesByComponent: mistakesByComponent ?? this.mistakesByComponent,
      );

  Map<String, Object?> toJson() => {
        'viewed': viewedComponents.toList(),
        'sims': usedSimulations.toList(),
        'cases': completedCases.toList(),
        'scores': bestScores,
        'competencies': {
          for (final e in competencies.entries) e.key.name: e.value.toJson(),
        },
        'mistakes': mistakesByComponent,
      };

  factory LearningProgress.fromJson(Map<String, Object?> json) {
    Set<String> readSet(String key) {
      final raw = json[key];
      if (raw is! List) return <String>{};
      return raw.whereType<String>().toSet();
    }

    Map<String, int> readIntMap(String key) {
      final raw = json[key];
      if (raw is! Map) return <String, int>{};
      return {
        for (final e in raw.entries)
          if (e.key is String && e.value is num)
            e.key as String: (e.value as num).toInt(),
      };
    }

    final rawComp = json['competencies'];
    final comps = <Competency, CompetencyStat>{};
    if (rawComp is Map) {
      for (final c in Competency.values) {
        final value = rawComp[c.name];
        if (value is Map<String, Object?>) {
          comps[c] = CompetencyStat.fromJson(value);
        }
      }
    }

    return LearningProgress(
      viewedComponents: readSet('viewed'),
      usedSimulations: readSet('sims'),
      completedCases: readSet('cases'),
      bestScores: readIntMap('scores'),
      competencies: comps,
      mistakesByComponent: readIntMap('mistakes'),
    );
  }
}
