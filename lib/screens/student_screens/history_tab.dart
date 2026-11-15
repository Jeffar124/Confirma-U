import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/models/user_model.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/course_dropdown.dart';
import '../../widgets/status_chip.dart';

/// "Mi historial": cursos reales desde Firestore, registros de ejemplo.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key, required this.user});
  final UserModel user;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late final Stream<List<CourseModel>> _stream = FirestoreService.instance
      .studentCourses(widget.user.email);
  String? _courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: 'Mi historial',
        subtitle: 'Revisa tu asistencia por curso.',
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: _stream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final courses = snap.data!;
          if (courses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Cuando te inscriban en un curso verás aquí tu historial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }
          var selected = _courseId ?? courses.first.id;
          if (!courses.any((c) => c.id == selected))
            selected = courses.first.id;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Curso',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              CourseDropdown(
                courses: courses,
                selectedId: selected,
                onChanged: (v) => setState(() => _courseId = v),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asistencia acumulada',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '$mockAttendancePercent%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '$mockAttendedClasses de $mockTotalClasses clases',
                          style: TextStyle(color: Colors.white, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: mockAttendancePercent / 100,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Clases recientes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              for (final h in mockHistory) ...[
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.dateFormatted,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              h.displayDetail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip.attendance(h.status),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}
