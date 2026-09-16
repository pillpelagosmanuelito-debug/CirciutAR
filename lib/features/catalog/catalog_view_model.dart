import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/electronic_component.dart';
import '../../domain/models/learning_module.dart';
import '../../providers/providers.dart';

class CatalogState {
  const CatalogState({
    required this.query,
    required this.category,
    required this.results,
  });

  final String query;
  final ComponentCategory? category;
  final List<ElectronicComponent> results;
}

/// ViewModel del catálogo: búsqueda sin tildes y filtro por categoría.
class CatalogViewModel extends Notifier<CatalogState> {
  @override
  CatalogState build() => _compute('', null);

  CatalogState _compute(String query, ComponentCategory? category) {
    final repo = ref.read(componentRepositoryProvider);
    return CatalogState(
      query: query,
      category: category,
      results: repo.search(query, category: category),
    );
  }

  void setQuery(String query) => state = _compute(query, state.category);

  void setCategory(ComponentCategory? category) =>
      state = _compute(state.query, category);

  void clear() => state = _compute('', null);
}

final catalogViewModelProvider =
    NotifierProvider<CatalogViewModel, CatalogState>(CatalogViewModel.new);
