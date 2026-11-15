import 'package:confirma_u/models/user_model.dart';
import 'package:confirma_u/screens/teacher_screens/reports_view.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

/// Pantalla reutilizable de Reportes de Asistencia para docentes.
///
/// Se utiliza tanto en la pestaña principal de [TeacherHomeScreen]
/// como al pulsar "Ver reporte" desde [CourseDetailScreen].
class TeacherReportsTab extends StatelessWidget {
  const TeacherReportsTab({
    super.key,
    this.user,
    this.teacherId,
    this.initialCourseId,
    this.subtitle,
    this.showBackButton = false,
  });

  final UserModel? user;
  final String? teacherId;
  final String? initialCourseId;
  final String? subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final uid = teacherId ??
        user?.uid ??
        AuthService.instance.currentUser?.uid ??
        '';

    return Scaffold(
      appBar: DefaultAppBar(
        title: 'Reporte de asistencia',
        subtitle: subtitle,
        showBackButton: showBackButton,
      ),
      body: ReportsView(
        teacherId: uid,
        initialCourseId: initialCourseId,
      ),
    );
  }
}
