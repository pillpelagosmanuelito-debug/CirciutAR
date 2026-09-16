import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/learning_repository.dart';
import '../../domain/models/competency.dart';
import '../../domain/models/question.dart';
import '../../providers/providers.dart';

class QuizState {
  const QuizState({
    required this.quiz,
    required this.index,
    required this.results,
    required this.finished,
  });

  final Quiz quiz;
  final int index;

  /// Resultado por índice de pregunta.
  final Map<int, AnswerResult> results;
  final bool finished;

  Question get current => quiz.questions[index];
  AnswerResult? get currentResult => results[index];
  bool get isLast => index == quiz.questions.length - 1;
  int get total => quiz.questions.length;
  int get correctCount => results.values.where((r) => r.correct).length;
  int get percent => total == 0 ? 0 : (correctCount * 100 / total).round();

  /// Aciertos y totales por competencia dentro de esta evaluación.
  Map<Competency, (int correct, int total)> get byCompetency {
    final map = <Competency, (int, int)>{};
    for (var i = 0; i < quiz.questions.length; i++) {
      final c = quiz.questions[i].competency;
      final prev = map[c] ?? (0, 0);
      final ok = results[i]?.correct ?? false;
      map[c] = (prev.$1 + (ok ? 1 : 0), prev.$2 + 1);
    }
    return map;
  }

  /// Preguntas respondidas incorrectamente.
  List<Question> get missed => [
        for (var i = 0; i < quiz.questions.length; i++)
          if (results[i]?.correct == false) quiz.questions[i],
      ];

  QuizState copyWith({
    int? index,
    Map<int, AnswerResult>? results,
    bool? finished,
  }) =>
      QuizState(
        quiz: quiz,
        index: index ?? this.index,
        results: results ?? this.results,
        finished: finished ?? this.finished,
      );
}

/// ViewModel de una evaluación o práctica.
class QuizViewModel extends AutoDisposeFamilyNotifier<QuizState, String> {
  @override
  QuizState build(String arg) {
    final repo = ref.watch(learningRepositoryProvider);
    final seed = QuizIds.isPractice(arg)
        ? DateTime.now().microsecondsSinceEpoch
        : null;
    return QuizState(
      quiz: repo.quiz(arg, seed: seed),
      index: 0,
      results: const {},
      finished: false,
    );
  }

  void selectOption(int optionIndex) {
    if (state.currentResult != null || state.finished) return;
    final result = ref
        .read(answerEvaluatorProvider)
        .evaluateOption(state.current, optionIndex);
    _store(result);
  }

  void submitNumeric(String input) {
    if (state.currentResult != null || state.finished) return;
    if (input.trim().isEmpty) return;
    final result = ref
        .read(answerEvaluatorProvider)
        .evaluateNumeric(state.current, input);
    _store(result);
  }

  void _store(AnswerResult result) {
    final q = state.current;
    state = state.copyWith(results: {...state.results, state.index: result});
    unawaited(ref.read(progressProvider.notifier).recordAnswer(
          competency: q.competency,
          correct: result.correct,
          componentId: q.componentId,
        ));
  }

  void next() {
    if (state.currentResult == null) return;
    if (state.isLast) {
      state = state.copyWith(finished: true);
      if (!QuizIds.isPractice(state.quiz.id)) {
        unawaited(ref
            .read(progressProvider.notifier)
            .recordQuizScore(state.quiz.id, state.percent));
      }
      return;
    }
    state = state.copyWith(index: state.index + 1);
  }

  void restart() {
    ref.invalidateSelf();
  }
}

final quizViewModelProvider = NotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, String>(QuizViewModel.new);
