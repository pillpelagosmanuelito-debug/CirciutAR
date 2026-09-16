import 'package:flutter/material.dart';

import '../../domain/models/learning_module.dart';
import '../../domain/simulation/simulation.dart';

/// Paleta y tema visual de CircuitAR.
abstract final class AppTheme {
  static const Color seed = Color(0xFF00796B);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static Color moduleColor(ModuleId id) => switch (id) {
        ModuleId.passive => const Color(0xFF00897B),
        ModuleId.active => const Color(0xFF5E35B1),
        ModuleId.semiconductors => const Color(0xFFEF6C00),
        ModuleId.sensors => const Color(0xFF1E88E5),
        ModuleId.applications => const Color(0xFF43A047),
        ModuleId.assessments => const Color(0xFFD81B60),
      };

  static IconData moduleIcon(ModuleId id) => switch (id) {
        ModuleId.passive => Icons.linear_scale,
        ModuleId.active => Icons.memory,
        ModuleId.semiconductors => Icons.bolt,
        ModuleId.sensors => Icons.sensors,
        ModuleId.applications => Icons.engineering,
        ModuleId.assessments => Icons.fact_check,
      };

  static Color categoryColor(ComponentCategory c) => moduleColor(c.module);

  static Color messageColor(MessageLevel level) => switch (level) {
        MessageLevel.info => const Color(0xFF1E88E5),
        MessageLevel.success => const Color(0xFF2E7D32),
        MessageLevel.warning => const Color(0xFFEF6C00),
        MessageLevel.danger => const Color(0xFFC62828),
      };

  static IconData messageIcon(MessageLevel level) => switch (level) {
        MessageLevel.info => Icons.info_outline,
        MessageLevel.success => Icons.check_circle_outline,
        MessageLevel.warning => Icons.warning_amber_rounded,
        MessageLevel.danger => Icons.dangerous_outlined,
      };
}
