import 'package:confirma_u/models/student_model.dart';
import 'package:confirma_u/utils/validator_form.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:confirma_u/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'add_student_screen.dart';

const _methods = [
  ('ble', 'Proximidad (BLE)', 'Detecta el dispositivo del docente.'),
  ('challenge', 'Reto rápido', 'El estudiante elige el emoji correcto.'),
  ('double', 'Doble validación', 'Primero proximidad, luego el reto.'),
];

const _minuteOptions = [1, 2, 3, 5, 10, 15];

class RegisterCourseScreen extends StatefulWidget {
  const RegisterCourseScreen({super.key, required this.teacherId});
  final String teacherId;

  @override
  State<RegisterCourseScreen> createState() => _RegisterCourseScreenState();
}

class _RegisterCourseScreenState extends State<RegisterCourseScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _schedule = TextEditingController();
  final _room = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  DateTime? _start;
  DateTime? _end;
  String _method = 'double';
  int _minutes = 5;
  final List<StudentModel> _students = [];
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _code, _schedule, _room, _startCtrl, _endCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        _startCtrl.text = fullDate(picked);
      } else {
        _end = picked;
        _endCtrl.text = fullDate(picked);
      }
    });
  }

  void _addStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(
          subtitle: _name.text.trim().isEmpty ? null : _name.text.trim(),
          onSave: (s) async {
            if (!mounted) return;
            // Validar que el correo no esté ya en la lista local.
            final exists = _students.any(
              (existing) =>
                  existing.email.toLowerCase() == s.email.toLowerCase(),
            );
            if (exists) {
              throw Exception('duplicate');
            }
            setState(() => _students.add(s));
          },
          duplicateEmailError:
              'Ya existe un estudiante con este correo en la lista.',
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_start == null || _end == null) {
      showSoon(context, 'Selecciona la fecha de inicio y de fin.');
      return;
    }
    if (_end!.isBefore(_start!)) {
      showSoon(context, 'La fecha de fin debe ser posterior al inicio.');
      return;
    }
    setState(() => _saving = true);
    try {
      await FirestoreService.instance.createCourse(
        CourseModel(
          teacherId: widget.teacherId,
          name: _name.text.trim(),
          code: _code.text.trim().toUpperCase(),
          schedule: _schedule.text.trim(),
          room: _room.text.trim(),
          method: _method,
          minutes: _minutes,
          startDate: _start,
          endDate: _end,
        ),
        _students,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showSoon(context, 'No se pudo guardar el curso. Intenta de nuevo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(title: 'Registrar curso'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configura la clase y el método de validación.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Nombre del curso',
                hintText: 'Diseño de Interfaces',
                controller: _name,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Código del curso',
                hintText: 'DIS 304',
                controller: _code,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Horario',
                hintText: 'Lun y Mié 10:00 – 11:30',
                controller: _schedule,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Salón',
                hintText: 'Aula B-204',
                controller: _room,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Fecha de inicio',
                      hintText: 'dd/mm/aaaa',
                      controller: _startCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(isStart: true),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Fecha de fin',
                      hintText: 'dd/mm/aaaa',
                      controller: _endCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(isStart: false),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Estudiantes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const Text(
                'Agrega quienes pertenecerán al curso.',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Cargar Excel · Carga masiva',
                icon: Icons.upload_file_outlined,
                // TODO: importar estudiantes desde Excel.
                onPressed: () => showSoon(context),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Agregar estudiante · Registro individual',
                icon: Icons.person_add_alt,
                onPressed: _addStudent,
              ),
              const SizedBox(height: 10),
              if (_students.isEmpty)
                AppCard(
                  color: AppColors.bg,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    children: [
                      Text(
                        'No hay estudiantes registrados',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Agrega estudiantes manualmente o carga una lista desde Excel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              else
                for (var i = 0; i < _students.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.greenSoft,
                            child: Text(
                              initials(_students[i].name),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.green,
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
                                  _students[i].name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  _students[i].email,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.red,
                            ),
                            onPressed: () =>
                                setState(() => _students.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              const Text(
                'Método de asistencia',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              for (final m in _methods) ...[
                _MethodOption(
                  title: m.$2,
                  description: m.$3,
                  selected: _method == m.$1,
                  onTap: () => setState(() => _method = m.$1),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              const Text(
                'Tiempo para decir presente',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _minutes,
                    items: [
                      for (final m in _minuteOptions)
                        DropdownMenuItem(
                          value: m,
                          child: Text(m == 1 ? '1 minuto' : '$m minutos'),
                        ),
                    ],
                    onChanged: (v) => setState(() => _minutes = v ?? _minutes),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Guardar curso',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? AppColors.green : AppColors.border,
      color: selected ? AppColors.greenSoft : Colors.white,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? AppColors.green : AppColors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
