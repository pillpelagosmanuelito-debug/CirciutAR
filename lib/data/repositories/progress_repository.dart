import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/progress.dart';

/// Persistencia del progreso del estudiante.
abstract class ProgressRepository {
  LearningProgress load();
  Future<void> save(LearningProgress progress);
  Future<void> clear();
}

/// Guarda el progreso en el dispositivo; la app funciona sin conexión.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._prefs);

  static const storageKey = 'circuitar.progress.v1';

  final SharedPreferences _prefs;

  @override
  LearningProgress load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return LearningProgress.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        return LearningProgress.fromJson(decoded);
      }
    } on FormatException {
      // Un dato corrupto no debe impedir que la app abra.
    }
    return LearningProgress.empty;
  }

  @override
  Future<void> save(LearningProgress progress) =>
      _prefs.setString(storageKey, jsonEncode(progress.toJson()));

  @override
  Future<void> clear() => _prefs.remove(storageKey);
}

/// Implementación en memoria para pruebas.
class InMemoryProgressRepository implements ProgressRepository {
  InMemoryProgressRepository([this._value = LearningProgress.empty]);

  LearningProgress _value;
  int saveCount = 0;

  @override
  LearningProgress load() => _value;

  @override
  Future<void> save(LearningProgress progress) async {
    _value = progress;
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _value = LearningProgress.empty;
  }
}
