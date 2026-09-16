import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/comparison.dart';
import '../../providers/providers.dart';

class ComparisonState {
  const ComparisonState({
    required this.leftId,
    required this.rightId,
    required this.view,
  });

  final String leftId;
  final String rightId;
  final ComparisonView? view;

  bool get sameComponent => leftId == rightId;
}

/// Argumento del comparador: par inicial de componentes.
typedef ComparisonArgs = ({String left, String? right});

/// ViewModel del comparador de componentes.
class ComparisonViewModel
    extends AutoDisposeFamilyNotifier<ComparisonState, ComparisonArgs> {
  @override
  ComparisonState build(ComparisonArgs arg) {
    final repo = ref.watch(componentRepositoryProvider);
    final left = repo.findById(arg.left) == null ? 'bjt_npn' : arg.left;
    final requested = arg.right;
    final right = requested != null && repo.findById(requested) != null
        ? requested
        : _defaultPartner(left);
    return _compute(left, right);
  }

  String _defaultPartner(String left) {
    final repo = ref.read(componentRepositoryProvider);
    final curated = repo.curatedFor(left);
    if (curated.isNotEmpty) {
      final first = curated.first;
      return first.aId == left ? first.bId : first.aId;
    }
    return repo.all().firstWhere((c) => c.id != left).id;
  }

  ComparisonState _compute(String left, String right) {
    final repo = ref.read(componentRepositoryProvider);
    return ComparisonState(
      leftId: left,
      rightId: right,
      view: left == right ? null : repo.compare(left, right),
    );
  }

  void setLeft(String id) => state = _compute(id, state.rightId);

  void setRight(String id) => state = _compute(state.leftId, id);

  void swap() => state = _compute(state.rightId, state.leftId);
}

final comparisonViewModelProvider = NotifierProvider.autoDispose
    .family<ComparisonViewModel, ComparisonState, ComparisonArgs>(
  ComparisonViewModel.new,
);
