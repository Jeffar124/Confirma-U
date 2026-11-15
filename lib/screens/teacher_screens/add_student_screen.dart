import 'package:confirma_u/models/student_model.dart';
import 'package:confirma_u/utils/validator_form.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Formulario reutilizable: lo usan "Registrar curso" (lista local)
/// y el detalle del curso (guarda directo en Firestore) mediante [onSave].
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({
    super.key,
    required this.onSave,
    this.initial,
    this.subtitle,
    this.duplicateEmailError,
  });

  final Future<void> Function(StudentModel student) onSave;
  final StudentModel? initial;
  final String? subtitle;

  /// Mensaje que se muestra cuando el callback [onSave] lanza una excepción
  /// con message 'duplicate'. Si es null usa un mensaje genérico.
  final String? duplicateEmailError;

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _form = GlobalKey<FormState>();
  late final _program = TextEditingController(text: widget.initial?.program);
  late final _code = TextEditingController(text: widget.initial?.code);
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _email = TextEditingController(text: widget.initial?.email);
  late final _doc = TextEditingController(text: widget.initial?.document);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  bool _saving = false;

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_program, _code, _name, _email, _doc, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final s = StudentModel(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      program: _program.text.trim(),
      code: _code.text.trim(),
      email: _email.text.trim(),
      document: _doc.text.trim(),
      phone: _phone.text.trim(),
    );
    try {
      await widget.onSave(s);
      if (!mounted) return;
      if (_editing) {
        Navigator.pop(context);
      } else {
        // "Podrás agregar otro al terminar": limpiamos el formulario.
        for (final c in [_program, _code, _name, _email, _doc, _phone]) {
          c.clear();
        }
        _form.currentState!.reset();
        showSoon(context, 'Estudiante agregado');
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('duplicate')
            ? (widget.duplicateEmailError ??
                'Este estudiante ya está inscrito.')
            : 'No se pudo guardar. Intenta de nuevo.';
        showSoon(context, msg);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 12),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        color: AppColors.green,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        title: _editing ? 'Editar estudiante' : 'Agregar estudiante al curso',
        subtitle: widget.subtitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registra los datos de un estudiante. Podrás agregar otro al terminar.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _section('Información académica'),
              AppTextField(
                label: 'Programa',
                hintText: 'Ej. Ingeniería de Sistemas',
                controller: _program,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Código de estudiante',
                hintText: 'Ej. 2026001',
                controller: _code,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 16),
              _section('Información personal'),
              AppTextField(
                label: 'Nombre completo',
                hintText: 'Ej. Juan Pérez',
                controller: _name,
                validator: ValidatorForm.requiredValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Correo institucional',
                hintText: 'nombre@udla.edu.co',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: ValidatorForm.validateEmail,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Documento',
                hintText: 'Número de documento',
                controller: _doc,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Teléfono',
                hintText: 'Número de teléfono',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _editing
                          ? 'Guardar cambios'
                          : 'Agregar estudiante',
                      isLoading: _saving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSoon(BuildContext context, [String msg = 'Disponible próximamente']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
