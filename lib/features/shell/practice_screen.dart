import 'package:flutter/material.dart';

import '../assessment/quiz_list_screen.dart';
import '../assistant/assistant_screen.dart';
import '../cases/case_screens.dart';
import '../comparison/comparison_screen.dart';
import '../identification/identification_screens.dart';
import '../simulation/lab_list_screen.dart';

/// Pestaña «Práctica»: acceso a todas las herramientas interactivas.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => screen),
        );

    final tools = <_Tool>[
      _Tool(
        icon: Icons.science_outlined,
        title: 'Laboratorio de simulaciones',
        subtitle: 'Un circuito típico por componente, con resultados al instante.',
        onTap: () => open(const LabListScreen()),
      ),
      _Tool(
        icon: Icons.visibility_outlined,
        title: 'Identificación visual',
        subtitle: 'Código de colores, galería y práctica de símbolos.',
        onTap: () => open(const IdentificationHubScreen()),
      ),
      _Tool(
        icon: Icons.compare_arrows,
        title: 'Comparador',
        subtitle: 'Dos componentes lado a lado y cuándo elegir cada uno.',
        onTap: () => open(const ComparisonScreen()),
      ),
      _Tool(
        icon: Icons.alt_route,
        title: 'Asistente de selección',
        subtitle: 'Describe tu necesidad y recibe una recomendación justificada.',
        onTap: () => open(const AssistantScreen()),
      ),
      _Tool(
        icon: Icons.engineering,
        title: 'Casos prácticos',
        subtitle: 'Diseña circuitos reales paso a paso.',
        onTap: () => open(const CaseListScreen()),
      ),
      _Tool(
        icon: Icons.fact_check_outlined,
        title: 'Evaluaciones',
        subtitle: 'Por módulo, de símbolos e integral.',
        onTap: () => open(const QuizListScreen()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Práctica')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final t = tools[i];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(child: Icon(t.icon)),
              title: Text(t.title),
              subtitle: Text(t.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: t.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _Tool {
  const _Tool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
