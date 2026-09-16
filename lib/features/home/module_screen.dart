import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../domain/models/learning_module.dart';
import '../../providers/providers.dart';
import '../catalog/catalog_screen.dart';

/// Módulos 1 a 4: objetivos y componentes de la categoría.
class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.moduleId});

  final ModuleId moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(componentRepositoryProvider);
    final module = repo.module(moduleId);
    final category = module.category;
    final components =
        category == null ? const <Never>[] : repo.byCategory(category);
    final viewed = ref.watch(progressProvider).viewedComponents;
    final seen = components.where((c) => viewed.contains(c.id)).length;
    final color = AppTheme.moduleColor(moduleId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Módulo ${module.number}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withAlpha(35),
                child: Icon(AppTheme.moduleIcon(moduleId), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title, style: theme.textTheme.titleLarge),
                    Text(module.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(module.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Al terminar podrás',
            icon: Icons.flag_outlined,
            child: BulletList(module.objectives, icon: Icons.check),
          ),
          if (components.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text('Componentes', style: theme.textTheme.titleMedium),
                ),
                Text('$seen de ${components.length} revisados'),
              ],
            ),
            const SizedBox(height: 8),
            for (final c in components) ComponentTile(component: c),
          ],
        ],
      ),
    );
  }
}
