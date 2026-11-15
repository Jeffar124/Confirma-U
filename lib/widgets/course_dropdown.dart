import 'package:confirma_u/models/course_model.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CourseDropdown extends StatelessWidget {
  const CourseDropdown({
    super.key,
    required this.courses,
    required this.selectedId,
    required this.onChanged,
  });

  final List<CourseModel> courses;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedId,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          items: [
            for (final c in courses)
              DropdownMenuItem(
                value: c.id,
                child: Text('${c.name} · ${c.code}'),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
