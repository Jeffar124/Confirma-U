import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/models/student_model.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import 'add_student_screen.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key, required this.course});
  final CourseModel course;

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  late final Stream<List<StudentModel>> _stream = FirestoreService.instance
      .students(widget.course.id);
  String _query = '';

  void _add() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(
          subtitle: '${widget.course.code} · ${widget.course.name}',
          onSave: (s) async {
            // Validar que el correo no esté ya inscrito en el curso.
            if (widget.course.studentEmails
                .map((e) => e.toLowerCase())
                .contains(s.email.toLowerCase())) {
              throw Exception('duplicate');
            }
            await FirestoreService.instance
                .saveStudent(widget.course.id, s);
          },
          duplicateEmailError:
              'Este correo ya está inscrito en el curso.',
        ),
      ),
    );
  }

  void _edit(StudentModel s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(
          initial: s,
          subtitle: '${widget.course.code} · ${widget.course.name}',
          onSave: (updated) => FirestoreService.instance.saveStudent(
            widget.course.id,
            updated,
            previousEmail: s.email,
          ),
        ),
      ),
    );
  }

  Future<void> _delete(StudentModel s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text('¿Quitar a ${s.name} de este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true)
      await FirestoreService.instance.deleteStudent(widget.course.id, s);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudentModel>>(
      stream: _stream,
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final all = snap.data!;
        final q = _query.trim().toLowerCase();
        final list = q.isEmpty
            ? all
            : all
                  .where(
                    (s) =>
                        s.name.toLowerCase().contains(q) ||
                        s.code.toLowerCase().contains(q) ||
                        s.document.toLowerCase().contains(q),
                  )
                  .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Estudiantes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              '${all.length} estudiantes inscritos en este curso.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, código o documento',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Agregar estudiante',
              icon: Icons.person_add_alt,
              onPressed: _add,
            ),
            const SizedBox(height: 18),
            Text(
              '${all.length} estudiantes registrados',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay estudiantes para mostrar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            for (final s in list) ...[
              _StudentCard(
                student: s,
                onEdit: () => _edit(s),
                onDelete: () => _delete(s),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });
  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.greenSoft,
                child: Text(
                  initials(student.name),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      student.program,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                student.code,
                fg: AppColors.muted,
                bg: AppColors.greySoft,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('Documento', student.document)),
              Expanded(child: _field('Teléfono', student.phone)),
            ],
          ),
          const SizedBox(height: 8),
          _field('Correo', student.email),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.green),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 12.5)),
    ],
  );
}
