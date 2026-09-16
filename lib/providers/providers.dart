import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/component_repository.dart';
import '../data/repositories/learning_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../domain/models/competency.dart';
import '../domain/models/progress.dart';
import '../domain/services/answer_evaluator.dart';
import '../domain/simulation/simulation_registry.dart';

/// Se sobrescribe en `main()` con la instancia real.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider debe sobrescribirse en main().',
  ),
);

final componentRepositoryProvider = Provider<ComponentRepository>(
  (ref) => const LocalComponentRepository(),
);

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => LocalLearningRepository(ref.watch(componentRepositoryProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => LocalProgressRepository(ref.watch(sharedPreferencesProvider)),
);

final simulationRegistryProvider = Provider<SimulationRegistry>(
  (ref) => const SimulationRegistry(),
);

final answerEvaluatorProvider = Provider<AnswerEvaluator>(
  (ref) => AnswerEvaluator(ref.watch(simulationRegistryProvider)),
);

/// Estado global del progreso del estudiante.
class ProgressNotifier extends Notifier<LearningProgress> {
  @override
  LearningProgress build() => ref.watch(progressRepositoryProvider).load();

  ProgressRepository get _repo => ref.read(progressRepositoryProvider);

  Future<void> _update(LearningProgress next) async {
    state = next;
    await _repo.save(next);
  }

  Future<void> markComponentViewed(String id) async {
    if (state.viewedComponents.contains(id)) return;
    await _update(state.copyWith(
      viewedComponents: {...state.viewedComponents, id},
    ));
  }

  Future<void> markSimulationUsed(String id) async {
    if (state.usedSimulations.contains(id)) return;
    await _update(state.copyWith(
      usedSimulations: {...state.usedSimulations, id},
    ));
  }

  Future<void> markCaseCompleted(String id) async {
    if (state.completedCases.contains(id)) return;
    await _update(state.copyWith(
      completedCases: {...state.completedCases, id},
    ));
  }

  /// Registra una respuesta por competencia y, si es incorrecta, suma un
  /// error al componente para recomendar repaso.
  Future<void> recordAnswer({
    required Competency competency,
    required bool correct,
    String? componentId,
  }) async {
    final comps = Map<Competency, CompetencyStat>.of(state.competencies);
    comps[competency] = state.statFor(competency).add(isCorrect: correct);
    final mistakes = Map<String, int>.of(state.mistakesByComponent);
    if (componentId != null) {
      if (correct) {
        final current = mistakes[componentId] ?? 0;
        if (current > 0) mistakes[componentId] = current - 1;
      } else {
        mistakes[componentId] = (mistakes[componentId] ?? 0) + 1;
      }
    }
    await _update(state.copyWith(
      competencies: comps,
      mistakesByComponent: mistakes,
    ));
  }

  Future<void> recordQuizScore(String quizId, int percent) async {
    final best = state.bestScores[quizId] ?? -1;
    if (percent <= best) return;
    await _update(state.copyWith(
      bestScores: {...state.bestScores, quizId: percent},
    ));
  }

  Future<void> reset() async {
    state = LearningProgress.empty;
    await _repo.clear();
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, LearningProgress>(
  ProgressNotifier.new,
);
