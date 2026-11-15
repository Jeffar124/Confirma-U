import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/primary_button.dart';
import 'course_detail_screen.dart';
import 'register_course_screen.dart';

class TeacherCoursesTab extends StatelessWidget {
  const TeacherCoursesTab({super.key, this.user});
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid ?? AuthService.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<CourseModel>>(
      stream: FirestoreService.instance.teacherCourses(uid),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                username: user != null
                    ? 'Bienvenido, ${user!.name.split(' ').first}'
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabecera de sección: "MIS CURSOS" y contador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MIS CURSOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${courses.length} cursos',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estado de carga
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (courses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Aún no tienes cursos',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Crea tu primer curso para comenzar a registrar asistencia.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Lista de cursos
                      ...courses.map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildCourseCard(context, course),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Botón "+ Nuevo curso"
                    PrimaryButton(
                      icon: Icons.add,
                      label: 'Nuevo curso',
                      color: AppColors.primary,
                      borderRadius: 10,
                      height: 48,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterCourseScreen(teacherId: uid),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mapeo de [CourseStatus] del modelo a colores visuales.
Color _statusBg(CourseStatus s) {
  switch (s) {
    case CourseStatus.enCurso:
      return const Color(0xFFE2F4EB);
    case CourseStatus.proxima:
      return const Color(0xFFEBF0FE);
    case CourseStatus.finalizada:
      return const Color(0xFFEEF0F2);
  }
}

Color _statusFg(CourseStatus s) {
  switch (s) {
    case CourseStatus.enCurso:
      return const Color(0xFF1E6B4A);
    case CourseStatus.proxima:
      return const Color(0xFF2563EB);
    case CourseStatus.finalizada:
      return const Color(0xFF6B7280);
  }
}

String _statusLabel(CourseStatus s) {
  switch (s) {
    case CourseStatus.enCurso:
      return 'En curso';
    case CourseStatus.proxima:
      return 'Próxima';
    case CourseStatus.finalizada:
      return 'Finalizada';
  }
}

Color _statusAccent(CourseStatus s) {
  switch (s) {
    case CourseStatus.enCurso:
      return const Color(0xFFE08E1A);
    case CourseStatus.proxima:
      return AppColors.primary;
    case CourseStatus.finalizada:
      return AppColors.primary;
  }
}

Widget _buildCourseCard(BuildContext context, CourseModel course) {
  final status = course.status;
  return AppCard(
    accent: _statusAccent(status),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailScreen(courseId: course.id),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila superior: Código y Badge de estado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              course.code,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _statusBg(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusFg(status),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Título del curso
        Text(
          course.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Horario
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              course.schedule,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Ubicación
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              course.room,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Estudiantes inscritos
        Row(
          children: [
            const Icon(
              Icons.people_outline,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '${course.studentCount} estudiantes',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    ),
  );
}
