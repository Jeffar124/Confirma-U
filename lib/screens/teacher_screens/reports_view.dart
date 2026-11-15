import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/models/student_model.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/course_dropdown.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import 'add_student_screen.dart' show showSoon;

/// Contenido de "Reporte de asistencia" (General del curso / Por clase).
/// Cursos y estudiantes vienen de Firestore; las fallas y estados son de ejemplo.
class ReportsView extends StatefulWidget {
  const ReportsView({super.key, required this.teacherId, this.initialCourseId});
  final String teacherId;
  final String? initialCourseId;

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  //Datos de Ejemplo TODO Quitar proximamente
  static const _fallas = [0, 2, 4, 0, 1, 1];
  static const _statuses = [
    'Presente',
    'Tarde',
    'Presente',
    'Ausente',
    'Justificado',
    'Presente',
  ];
  String mockStatusFor(int index) => _statuses[index % _statuses.length];
  int mockFallasFor(int index) => _fallas[index % _fallas.length];

  late final Stream<List<CourseModel>> _courses = FirestoreService.instance
      .teacherCourses(widget.teacherId);
  Stream<List<StudentModel>>? _students;
  String? _studentsFor;
  String? _courseId;
  int _mode = 0; // 0 = general, 1 = por clase
  DateTime _date = DateTime.now();

  Stream<List<StudentModel>> _studentsStream(String id) {
    if (_studentsFor != id) {
      _studentsFor = id;
      _students = FirestoreService.instance.students(id);
    }
    return _students!;
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => _date = p);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CourseModel>>(
      stream: _courses,
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final courses = snap.data!;
        if (courses.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Crea un curso para ver sus reportes.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          );
        }
        var selected = _courseId ?? widget.initialCourseId ?? courses.first.id;
        if (!courses.any((c) => c.id == selected)) selected = courses.first.id;

        return StreamBuilder<List<StudentModel>>(
          stream: _studentsStream(selected),
          builder: (context, sSnap) {
            final students = sSnap.data ?? const <StudentModel>[];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Segments(
                  index: _mode,
                  labels: const ['General del curso', 'Por clase'],
                  onChanged: (i) => setState(() => _mode = i),
                ),
                const SizedBox(height: 14),
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
                if (_mode == 0)
                  ..._general(students)
                else
                  ..._perClass(students),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Exportar a Excel',
                  icon: Icons.download_outlined,
                  // TODO: exportar reporte real.
                  onPressed: () =>
                      showSoon(context, 'Exportación disponible próximamente'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _general(List<StudentModel> students) => [
    const Text(
      'Fallas por estudiante',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    ),
    const Text(
      'Acumulado de todas las clases del curso.',
      style: TextStyle(fontSize: 12.5, color: AppColors.muted),
    ),
    const SizedBox(height: 10),
    if (students.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Este curso aún no tiene estudiantes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      ),
    for (var i = 0; i < students.length; i++) ...[
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    students[i].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    students[i].code,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _fallasChip(mockFallasFor(i)),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ],
  ];

  Widget _fallasChip(int n) {
    final label = '$n ${n == 1 ? 'falla' : 'fallas'}';
    if (n == 0)
      return StatusChip(label, fg: AppColors.green, bg: AppColors.greenSoft);
    if (n == 1)
      return StatusChip(label, fg: AppColors.amber, bg: AppColors.amberSoft);
    return StatusChip(label, fg: AppColors.red, bg: AppColors.redSoft);
  }

  List<Widget> _perClass(List<StudentModel> students) {
    final statuses = [
      for (var i = 0; i < students.length; i++) mockStatusFor(i),
    ];
    int count(String s) => statuses.where((x) => x == s).length;
    final total = students.length;
    final pct = total == 0 ? 0 : (count('Presente') * 100 / total).round();

    return [
      const Text(
        'Fecha de la clase',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(fullDate(_date))),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      AppCard(
        borderColor: AppColors.green,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('$total', 'Total'),
                _stat('${count('Presente')}', 'Presentes'),
                _stat('${count('Tarde')}', 'Tarde'),
                _stat('${count('Ausente')}', 'Ausentes'),
                _stat('${count('Justificado')}', 'Justificados'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'RESUMEN DE LA CLASE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$total estudiantes',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            '$pct% presentes',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < students.length; i++) ...[
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  students[i].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
              StatusChip.attendance(statuses[i]),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
      ),
    ],
  );
}

class _Segments extends StatelessWidget {
  const _Segments({
    required this.index,
    required this.labels,
    required this.onChanged,
  });
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: i == index ? AppColors.green : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
