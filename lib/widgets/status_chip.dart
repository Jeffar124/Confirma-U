import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, required this.fg, required this.bg});
  final String label;
  final Color fg;
  final Color bg;

  /// Presente / Tarde / Ausente / Justificado
  factory StatusChip.attendance(String status) {
    switch (status) {
      case 'Presente':
        return StatusChip(status, fg: AppColors.green, bg: AppColors.greenSoft);
      case 'Tarde':
        return StatusChip(status, fg: AppColors.amber, bg: AppColors.amberSoft);
      case 'Ausente':
        return StatusChip(status, fg: AppColors.red, bg: AppColors.redSoft);
      default:
        return StatusChip(status, fg: AppColors.blue, bg: AppColors.blueSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
