import 'package:confirma_u/models/course_model.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'info_row.dart';
import 'primary_button.dart';
import 'status_chip.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  final CourseModel course;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    late final Color accent;
    late final Color bg;
    late final String label;
    switch (course.status) {
      case CourseStatus.enCurso:
        accent = AppColors.green;
        bg = AppColors.greenSoft;
        label = 'En curso';
        break;
      case CourseStatus.proxima:
        accent = AppColors.amber;
        bg = AppColors.amberSoft;
        label = 'Próxima';
        break;
      case CourseStatus.finalizada:
        accent = AppColors.grey;
        bg = AppColors.greySoft;
        label = 'Finalizada';
        break;
    }
    return AppCard(
      accent: accent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(label, fg: accent, bg: bg),
            ],
          ),
          const SizedBox(height: 6),
          InfoRow(Icons.schedule, course.schedule),
          InfoRow(Icons.place_outlined, course.room),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            PrimaryButton(label: actionLabel!, onPressed: onAction, height: 40),
          ],
        ],
      ),
    );
  }
}
