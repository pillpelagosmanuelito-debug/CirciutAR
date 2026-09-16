import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/resistor_view.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../data/repositories/learning_repository.dart';
import '../../domain/models/electronic_component.dart';
import '../../domain/simulation/color_code.dart';
import '../../domain/simulation/simulation.dart';
import '../../providers/providers.dart';
import '../assessment/quiz_screen.dart';
import '../catalog/component_detail_screen.dart';
import 'color_code_view_model.dart';

/// Centro de identificación visual.
class IdentificationHubScreen extends StatelessWidget {
  const IdentificationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => screen),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Identificación visual')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MessageTile(SimMessage(
            MessageLevel.info,
            'El reconocimiento con cámara no forma parte de esta versión: '
            'aquí entrenas la lectura de símbolos y códigos, que es lo que '
            'se evalúa en el curso.',
          )),
          _HubTile(
            icon: Icons.palette_outlined,
            title: 'Lector de código de colores',
            subtitle: 'Elige las bandas y obtén el valor y su tolerancia.',
            onTap: () => open(const ColorCodeScreen()),
          ),
          _HubTile(
            icon: Icons.grid_view,
            title: 'Galería de símbolos',
            subtitle: 'Todos los símbolos del catálogo con su descripción.',
            onTap: () => open(const SymbolGalleryScreen()),
          ),
          _HubTile(
            icon: Icons.quiz_outlined,
            title: 'Práctica: símbolos',
            subtitle: 'Diez símbolos al azar. No afecta tus puntajes.',
            onTap: () => open(const QuizScreen(quizId: QuizIds.symbolPractice)),
          ),
          _HubTile(
            icon: Icons.linear_scale,
            title: 'Práctica: código de colores',
            subtitle: 'Diez resistores al azar de la serie E12.',
            onTap: () => open(const QuizScreen(quizId: QuizIds.colorPractice)),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Lector interactivo del código de colores.
class ColorCodeScreen extends ConsumerWidget {
  const ColorCodeScreen({super.key});

  static String roleLabel(BandRole role, int index) => switch (role) {
        BandRole.digit => 'Cifra ${index + 1}',
        BandRole.multiplier => 'Multiplicador',
        BandRole.tolerance => 'Tolerancia',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(colorCodeViewModelProvider);
    final vm = ref.read(colorCodeViewModelProvider.notifier);
    final reading = state.reading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Código de colores')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('4 bandas'),
                  selected: state.bandCount == 4,
                  onSelected: (_) => vm.setBandCount(4),
                ),
                ChoiceChip(
                  label: const Text('5 bandas'),
                  selected: state.bandCount == 5,
                  onSelected: (_) => vm.setBandCount(5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResistorView(bands: state.bands, height: 90),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    EngFormat.format(reading.ohms, 'Ω'),
                    style: theme.textTheme.displaySmall,
                  ),
                  Text(
                    'Tolerancia ±${_tol(reading.tolerance)} % · entre '
                    '${EngFormat.format(reading.minOhms, 'Ω')} y '
                    '${EngFormat.format(reading.maxOhms, 'Ω')}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < state.bandCount; i++)
            SectionCard(
              title: '${roleLabel(state.roleOf(i), i)}: '
                  '${state.bands[i].label.toLowerCase()}',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final color in state.optionsFor(i))
                    _ColorDot(
                      color: color,
                      caption: caption(state.roleOf(i), color),
                      selected: state.bands[i] == color,
                      onTap: () => vm.setBand(i, color),
                    ),
                ],
              ),
            ),
          const MessageTile(SimMessage(
            MessageLevel.info,
            'Lee desde el extremo opuesto a la banda de tolerancia (dorada o '
            'plateada), que suele estar más separada. En resistores de '
            'precisión hay tres cifras y cinco bandas.',
          )),
        ],
      ),
    );
  }

  static String caption(BandRole role, BandColor color) => switch (role) {
        BandRole.digit => '${color.digit}',
        BandRole.multiplier => '×${_multiplier(color.multiplierExp ?? 0)}',
        BandRole.tolerance => '±${_tol(color.tolerance ?? 0)} %',
      };

  static String _multiplier(int exp) => switch (exp) {
        -2 => '0.01',
        -1 => '0.1',
        0 => '1',
        1 => '10',
        2 => '100',
        3 => '1k',
        4 => '10k',
        5 => '100k',
        _ => '1M',
      };

  static String _tol(double t) =>
      t == t.roundToDouble() ? t.toStringAsFixed(0) : t.toString();
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final BandColor color;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '${color.label} $caption',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Color(color.argb),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: selected ? 3 : 1,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: _contrastOn(Color(color.argb)),
                    )
                  : null,
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 58,
              child: Text(
                '${color.label}\n$caption',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _contrastOn(Color c) =>
      c.computeLuminance() > 0.4 ? Colors.black : Colors.white;
}

/// Galería de todos los símbolos del catálogo.
class SymbolGalleryScreen extends ConsumerWidget {
  const SymbolGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(componentRepositoryProvider).all();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Galería de símbolos')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemCount: components.length,
        itemBuilder: (context, i) {
          final c = components[i];
          final color = AppTheme.categoryColor(c.category);
          return Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => _SymbolSheet(component: c),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ComponentSymbol(c.symbol, width: 120, height: 80, color: color),
                    const SizedBox(height: 8),
                    Text(
                      c.shortName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SymbolSheet extends StatelessWidget {
  const _SymbolSheet({required this.component});

  final ElectronicComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ComponentSymbol(component.symbol, width: 200, height: 130),
            const SizedBox(height: 8),
            Text(component.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(component.symbol.description, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ComponentDetailScreen(componentId: component.id),
                  ),
                );
              },
              child: const Text('Abrir la ficha'),
            ),
          ],
        ),
      ),
    );
  }
}
