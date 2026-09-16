import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'quiz_screen.dart';

/// Módulo 6: lista de evaluaciones con el mejor puntaje obtenido.
class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzes = ref.watch(learningRepositoryProvider).quizzes();
    final scores = ref.watch(progressProvider).bestScores;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Cada respuesta se registra en tu progreso por competencia. Las '
            'preguntas numéricas aceptan coma o punto decimal.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final q in quizzes)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${q.questions.length}'),
                ),
                title: Text(q.title),
                subtitle: Text(q.description),
                trailing: scores[q.id] == null
                    ? const Icon(Icons.chevron_right)
                    : Text(
                        '${scores[q.id]} %',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(quizId: q.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
