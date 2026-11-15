import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/course_card.dart';
import 'attendance_flow_screen.dart';

class StudentCoursesTab extends StatefulWidget {
  const StudentCoursesTab({super.key, this.user});
  final UserModel? user;

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  late final Stream<List<CourseModel>> _stream = FirestoreService.instance
      .studentCourses(widget.user!.email);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          username: 'Bienvenido, ${widget.user!.name.split(' ').first}',
        ),
        Expanded(
          child: StreamBuilder<List<CourseModel>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se pudieron cargar los cursos.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                );
              }
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final courses = snap.data!;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'MIS CURSOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (courses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Aún no estás inscrito en ningún curso.\nTu docente te agrega con tu correo institucional.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  for (final c in courses) ...[
                    CourseCard(
                      course: c,
                      actionLabel: 'Decir presente',
                      // Habilitado en todos los estados para poder probar el flujo.
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceFlowScreen(course: c),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
