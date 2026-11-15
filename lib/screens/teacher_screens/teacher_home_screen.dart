import 'package:confirma_u/screens/teacher_screens/teacher_courses_tab.dart';
import 'package:confirma_u/screens/teacher_screens/teacher_reports_tab.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../common/profile_tab_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key, this.user});

  static const String routeName = '/teacher-home';
  final UserModel? user;

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUid = AuthService.instance.currentUser?.uid;

    return StreamBuilder<UserModel?>(
      stream: widget.user != null
          ? Stream.value(widget.user)
          : (currentUid != null
                ? UserService.instance.streamUser(currentUid)
                : Stream.value(null)),
      initialData: widget.user,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // 0: Pestaña CURSOS
              TeacherCoursesTab(user: user),

              // 1: Pestaña REPORTES
              TeacherReportsTab(),

              // 2: Pestaña PERFIL (reutilizando ProfileTab si hay usuario)
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

  // ── BARRA DE NAVEGACIÓN INFERIOR PERSONALIZADA ──────────────────────────────

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
            icon: Icons.bar_chart_rounded,
            label: 'REPORTES',
            isSelected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'PERFIL',
            isSelected: _currentIndex == 2,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    );
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
      // Estado seleccionado: botón tipo cápsula verde con texto e icono blanco
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

    // Estado no seleccionado: gris sobre fondo transparente
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
