import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'live_class_screen.dart';
import 'students_tab.dart';
import 'teacher_reports_tab.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final Stream<CourseModel?> _stream = FirestoreService.instance
      .courseStream(widget.courseId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CourseModel?>(
      stream: _stream,
      builder: (context, snap) {
        final c = snap.data;
        if (c == null) {
          return Scaffold(
            appBar: DefaultAppBar(title: 'Curso'),
            body: Center(
              child: snap.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text('Curso no encontrado'),
            ),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: DefaultAppBar(
              title: c.name,
              subtitle: '${c.code} · ${c.schedule}',
              bottom: const TabBar(
                labelColor: AppColors.green,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.green,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: 'Información general'),
                  Tab(text: 'Estudiantes'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _InfoTab(course: c),
                StudentsTab(course: c),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final period = (course.startDate != null && course.endDate != null)
        ? '${shortDate(course.startDate!)} – ${shortDate(course.endDate!)}'
        : '—';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: _tile('PERIODO', period)),
            const SizedBox(width: 10),
            Expanded(
              child: _tile('ESTUDIANTES', '${course.studentCount} inscritos'),
            ),
            const SizedBox(width: 10),
            Expanded(child: _tile('MÉTODO', course.methodLabel)),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Horario del curso',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.schedule,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          course.room,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Iniciar clase',
          icon: Icons.sensors,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LiveClassScreen(course: course)),
          ),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Ver reporte',
          icon: Icons.bar_chart,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherReportsTab(
                teacherId: course.teacherId,
                initialCourseId: course.id,
                subtitle: course.name,
                showBackButton: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(String label, String value) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
