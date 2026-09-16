import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/resistor_view.dart';
import '../../core/widgets/symbol_painter.dart';
import '../../domain/models/question.dart';
import '../../domain/simulation/simulation.dart';

/// Presenta una pregunta y su retroalimentación.
///
/// Es un widget de presentación puro: la lógica vive en el ViewModel que lo
/// usa (evaluación o caso práctico).
class QuestionView extends StatefulWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.result,
    required this.onSelectOption,
    required this.onSubmitNumeric,
  });

  final Question question;
  final AnswerResult? result;
  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onSubmitNumeric;

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.question;
    final result = widget.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(q.competency.label, color: theme.colorScheme.primary),
            if (q.type == QuestionType.numeric)
              TagChip('Cálculo', color: AppTheme.messageColor(MessageLevel.info)),
          ],
        ),
        const SizedBox(height: 12),
        Text(q.prompt, style: theme.textTheme.titleMedium),
        if (q.symbol != null) ...[
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ComponentSymbol(q.symbol!, width: 180, height: 120),
            ),
          ),
        ],
        if (q.bands != null) ...[
          const SizedBox(height: 16),
          ResistorView(bands: q.bands!),
        ],
        const SizedBox(height: 16),
        if (q.type == QuestionType.multipleChoice)
          ..._options(context, q, result)
        else
          _numeric(context, q, result),
        if (result != null) ...[
          const SizedBox(height: 12),
          MessageTile(SimMessage(
            result.correct ? MessageLevel.success : MessageLevel.danger,
            result.feedback,
          )),
          if (result.expected != null && !result.correct)
            MessageTile(SimMessage(
              MessageLevel.info,
              'Respuesta esperada: ${result.expected}',
            )),
          MessageTile(SimMessage(MessageLevel.info, q.explanation)),
        ],
      ],
    );
  }

  List<Widget> _options(BuildContext context, Question q, AnswerResult? result) {
    final theme = Theme.of(context);
    return [
      for (var i = 0; i < q.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OptionTile(
            label: q.options[i].text,
            letter: String.fromCharCode(65 + i),
            state: _optionState(q, i, result),
            onTap: result == null ? () => widget.onSelectOption(i) : null,
            theme: theme,
          ),
        ),
    ];
  }

  _OptionState _optionState(Question q, int i, AnswerResult? result) {
    if (result == null) return _OptionState.idle;
    if (q.options[i].correct) return _OptionState.correct;
    if (result.selectedIndex == i) return _OptionState.wrong;
    return _OptionState.disabled;
  }

  Widget _numeric(BuildContext context, Question q, AnswerResult? result) {
    final spec = q.numeric!;
    final answered = result != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: !answered,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: 'Tu respuesta',
              suffixText: spec.unitLabel,
              helperText: 'Tolerancia: ±${spec.tolerancePercent.toStringAsFixed(0)} %',
            ),
            onSubmitted: answered ? null : widget.onSubmitNumeric,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: answered
              ? null
              : () => widget.onSubmitNumeric(_controller.text),
          child: const Text('Comprobar'),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, disabled }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.letter,
    required this.state,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final String letter;
  final _OptionState state;
  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final success = AppTheme.messageColor(MessageLevel.success);
    final danger = AppTheme.messageColor(MessageLevel.danger);
    final (Color border, Color background, IconData? icon) = switch (state) {
      _OptionState.idle => (scheme.outlineVariant, scheme.surface, null),
      _OptionState.correct => (success, success.withAlpha(30), Icons.check_circle),
      _OptionState.wrong => (danger, danger.withAlpha(30), Icons.cancel),
      _OptionState.disabled => (scheme.outlineVariant, scheme.surface, null),
    };
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: border.withAlpha(40),
                child: Text(letter, style: theme.textTheme.labelLarge),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: state == _OptionState.disabled
                        ? scheme.onSurface.withAlpha(150)
                        : null,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: border),
            ],
          ),
        ),
      ),
    );
  }
}
