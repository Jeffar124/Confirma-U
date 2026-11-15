import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../common/profile_tab_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  static const String routeName = '/student-home';

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;

    return StreamBuilder<UserModel?>(
      stream: uid != null
          ? UserService.instance.streamUser(uid)
          : Stream.value(null),
      builder: (context, userSnap) {
        final user = userSnap.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // 0: Pestaña MIS CURSOS
              _StudentCoursesTab(user: user),

              // 1: Pestaña PERFIL
              user != null
                  ? ProfileTab(user: user)
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.chrome_reader_mode_outlined,
            label: 'CURSOS',
            isSelected: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'PERFIL',
            isSelected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
        ],
      ),
    );
  }
}

// ── PESTAÑA DE CURSOS DEL ESTUDIANTE ──────────────────────────────────────────

class _StudentCoursesTab extends StatelessWidget {
  const _StudentCoursesTab({this.user});
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final email = user?.email ??
        AuthService.instance.currentUser?.email ??
        '';

    if (email.isEmpty) {
      return const Center(
        child: Text('No se pudo obtener tu correo institucional.'),
      );
    }

    return StreamBuilder<List<CourseModel>>(
      stream: FirestoreService.instance.studentCourses(email),
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
                    ? 'Hola, ${user!.name.split(' ').first}'
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              'No estás inscrito en ningún curso',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tu docente debe agregar tu correo institucional al curso para que aparezca aquí.',
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
                      ...courses.map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildStudentCourseCard(course),
                        ),
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

Widget _buildStudentCourseCard(CourseModel course) {
  final status = course.status;
  return AppCard(
    accent: _statusAccent(status),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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

        // Método de asistencia
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              course.methodLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),

        // Periodo
        if (course.startDate != null && course.endDate != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${shortDate(course.startDate!)} – ${shortDate(course.endDate!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
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

// ── ITEM DEL BOTTOM NAVIGATION BAR ─────────────────────────────────────────────

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.textMuted),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
