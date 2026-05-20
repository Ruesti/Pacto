import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'shared/theme/app_theme.dart';

class PactoApp extends ConsumerWidget {
  const PactoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pacto',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
