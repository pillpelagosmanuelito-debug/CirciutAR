import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../domain/models/learning_module.dart';
import '../../providers/providers.dart';
import '../assessment/quiz_list_screen.dart';
import '../cases/case_screens.dart';
import 'module_screen.dart';

/// Pantalla de inicio: ruta de aprendizaje y los seis módulos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static void openModule(BuildContext context, ModuleId id) {
    final Widget screen = switch (id) {
      ModuleId.applications => const CaseListScreen(),
      ModuleId.assessments => const QuizListScreen(),
      _ => ModuleScreen(moduleId: id),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(componentRepositoryProvider);
    final learning = ref.watch(learningRepositoryProvider);
    final progress = ref.watch(progressProvider);
    final modules = repo.modules();
    final totalComponents = repo.all().length;
    final totalCases = learning.cases().length;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Icon(Icons.developer_board,
                    size: 34, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CircuitAR',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(
                        'Laboratorio de componentes electrónicos',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No memorices el componente: aprende cuándo y por qué usarlo.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Metric(
                          value: '${progress.viewedComponents.length}/$totalComponents',
                          label: 'Fichas',
                        ),
                        _Metric(
                          value:
                              '${progress.usedSimulations.length}/$totalComponents',
                          label: 'Simulaciones',
                        ),
                        _Metric(
                          value: '${progress.completedCases.length}/$totalCases',
                          label: 'Casos',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const SectionCard(
              title: 'Ruta sugerida para cada componente',
              icon: Icons.route_outlined,
              child: _Route(),
            ),
            Text('Módulos', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 600 ? 3 : 2;
                const spacing = 10.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final m in modules)
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          module: m,
                          onTap: () => openModule(context, m.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Route extends StatelessWidget {
  const _Route();

  static const _steps = [
    ('Explora', 'Lee la ficha: funcionamiento y características.'),
    ('Experimenta', 'Mueve los parámetros en su simulación.'),
    ('Compara', 'Contrástalo con el componente con el que se confunde.'),
    ('Aplica', 'Resuelve un caso real tomando decisiones.'),
    ('Evalúate', 'Mide tu dominio por competencia.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text('${i + 1}', style: theme.textTheme.labelSmall),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${_steps[i].$1}: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: _steps[i].$2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final LearningModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.moduleColor(module.id);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(35),
                child: Icon(AppTheme.moduleIcon(module.id), color: color),
              ),
              const SizedBox(height: 10),
              Text('Módulo ${module.number}',
                  style: theme.textTheme.labelSmall?.copyWith(color: color)),
              const SizedBox(height: 2),
              Text(
                module.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                module.subtitle,
                style: theme.textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
