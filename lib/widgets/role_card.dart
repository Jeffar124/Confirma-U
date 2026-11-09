import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Tarjeta seleccionable para escoger el rol del usuario (Estudiante o Docente).
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
    this.title,
    this.subtitle,
    this.icon,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;
  final String? title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isStudent = role == UserRole.estudiante;
    final String displayTitle =
        title ?? (isStudent ? 'Estudiante' : 'Docente');
    final String displaySubtitle = subtitle ??
        (isStudent
            ? 'Asiste y confirma clases'
            : 'Gestiona la asistencia');
    final IconData displayIcon = icon ??
        (isStudent ? Icons.school_outlined : Icons.co_present_outlined);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEAF5EE) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isSelected ? 0.06 : 0.02,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        displayIcon,
                        size: 22,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: isSelected ? AppColors.primary : AppColors.hint,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displaySubtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

