import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';

class CircuitArApp extends StatelessWidget {
  const CircuitArApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CircuitAR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
