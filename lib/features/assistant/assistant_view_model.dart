import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/assistant.dart';
import '../../providers/providers.dart';

/// Paso ya respondido del recorrido.
class AssistantStep {
  const AssistantStep({required this.node, required this.choice});

  final AssistantNode node;
  final int choice;

  String get answer => node.options[choice].label;
}

class AssistantState {
  const AssistantState({
    required this.current,
    required this.history,
    this.recommendation,
  });

  final AssistantNode current;
  final List<AssistantStep> history;
  final Recommendation? recommendation;

  bool get finished => recommendation != null;
  bool get canGoBack => history.isNotEmpty;
}

/// ViewModel del asistente de selección (árbol de decisión determinista).
class AssistantViewModel extends AutoDisposeNotifier<AssistantState> {
  @override
  AssistantState build() {
    final repo = ref.watch(learningRepositoryProvider);
    return AssistantState(
      current: repo.node(repo.assistantRoot),
      history: const [],
    );
  }

  void choose(int index) {
    if (state.finished) return;
    final node = state.current;
    if (index < 0 || index >= node.options.length) return;
    final option = node.options[index];
    final history = [
      ...state.history,
      AssistantStep(node: node, choice: index),
    ];
    final rec = option.recommendation;
    if (rec != null) {
      state = AssistantState(
        current: node,
        history: history,
        recommendation: rec,
      );
      return;
    }
    final repo = ref.read(learningRepositoryProvider);
    state = AssistantState(
      current: repo.node(option.nextId!),
      history: history,
    );
  }

  void back() {
    if (!state.canGoBack) return;
    final history = [...state.history]..removeLast();
    final previous = state.history.last.node;
    state = AssistantState(current: previous, history: history);
  }

  void restart() => ref.invalidateSelf();
}

final assistantViewModelProvider =
    NotifierProvider.autoDispose<AssistantViewModel, AssistantState>(
  AssistantViewModel.new,
);
