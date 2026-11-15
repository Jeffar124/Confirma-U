import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class TeacherReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reportes de Asistencia',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 72,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reportes y Métricas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Visualiza los reportes consolidados de asistencia de tus estudiantes por curso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
