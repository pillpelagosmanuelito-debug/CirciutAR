import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/practical_case.dart';
import '../../domain/models/question.dart';
import '../../providers/providers.dart';

enum CaseStage { intro, steps, summary }

class CaseState {
  const CaseState({
    required this.practicalCase,
    required this.stage,
    required this.step,
    required this.results,
  });

  final PracticalCase practicalCase;
  final CaseStage stage;
  final int step;
  final Map<int, AnswerResult> results;

  Question get currentStep => practicalCase.steps[step];
  AnswerResult? get currentResult => results[step];
  int get totalSteps => practicalCase.steps.length;
  bool get isLastStep => step == totalSteps - 1;
  int get correctCount => results.values.where((r) => r.correct).length;

  CaseState copyWith({
    CaseStage? stage,
    int? step,
    Map<int, AnswerResult>? results,
  }) =>
      CaseState(
        practicalCase: practicalCase,
        stage: stage ?? this.stage,
        step: step ?? this.step,
        results: results ?? this.results,
      );
}

/// ViewModel de un caso práctico: introducción, decisiones y cierre.
class CaseViewModel extends AutoDisposeFamilyNotifier<CaseState, String> {
  @override
  CaseState build(String arg) {
    final c = ref.watch(learningRepositoryProvider).caseById(arg);
    if (c == null) throw ArgumentError('Caso desconocido: $arg');
    return CaseState(
      practicalCase: c,
      stage: CaseStage.intro,
      step: 0,
      results: const {},
    );
  }

  void start() => state = state.copyWith(stage: CaseStage.steps, step: 0);

  void selectOption(int index) {
    if (state.stage != CaseStage.steps || state.currentResult != null) return;
    _store(ref
        .read(answerEvaluatorProvider)
        .evaluateOption(state.currentStep, index));
  }

  void submitNumeric(String input) {
    if (state.stage != CaseStage.steps || state.currentResult != null) return;
    if (input.trim().isEmpty) return;
    _store(ref
        .read(answerEvaluatorProvider)
        .evaluateNumeric(state.currentStep, input));
  }

  void _store(AnswerResult result) {
    final q = state.currentStep;
    state = state.copyWith(results: {...state.results, state.step: result});
    unawaited(ref.read(progressProvider.notifier).recordAnswer(
          competency: q.competency,
          correct: result.correct,
          componentId: q.componentId,
        ));
  }

  void next() {
    if (state.currentResult == null) return;
    if (state.isLastStep) {
      state = state.copyWith(stage: CaseStage.summary);
      unawaited(ref
          .read(progressProvider.notifier)
          .markCaseCompleted(state.practicalCase.id));
      return;
    }
    state = state.copyWith(step: state.step + 1);
  }

  void restart() => ref.invalidateSelf();
}

final caseViewModelProvider = NotifierProvider.autoDispose
    .family<CaseViewModel, CaseState, String>(CaseViewModel.new);
