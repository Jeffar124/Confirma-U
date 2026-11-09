import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/verification_service.dart';
import '../theme/app_theme.dart';
import '../utils/validator_form.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/send_code_button.dart';
import 'login_screen.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  static const String routeName = '/recuperar';

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _formKeyRecover = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _codeSent = false;

  /// El botón "Guardar nueva clave" se habilita cuando todos los campos tienen datos válidos
  /// y el código fue enviado.
  bool get _canSubmit =>
      _emailController.text.trim().isNotEmpty &&
      _codeController.text.trim().length == 4 &&
      _newPasswordController.text.isNotEmpty &&
      _codeSent;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _refresh(String _) => setState(() {});

  Future<bool> _sendCode() async {
    if (ValidatorForm.validateEmail(_emailController.text) != null) {
      // Muestra el error en el campo de correo si no es válido.
      _emailFieldKey.currentState?.validate();
      return false;
    }

    final result = await VerificationService.instance.sendCode(
      email: _emailController.text,
    );

    if (!mounted) return false;

    if (result.success) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📧 Código enviado a tu correo institucional'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Error al enviar el código.'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
  }

  Future<void> _saveButton() async {
    if (!_formKeyRecover.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await VerificationService.instance.resetPasswordWithCode(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Contraseña actualizada con éxito! Inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'No se pudo actualizar la contraseña.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Recupera tu clave'),
      body: Column(
        children: [
          const AuthSubtitle('Confirma tu correo y crea una nueva contraseña.'),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKeyRecover,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Correo institucional',
                        controller: _emailController,
                        hintText: 'nombre@udla.edu.co',
                        fieldKey: _emailFieldKey,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: ValidatorForm.validateEmail,
                        onChanged: (v) {
                          if (_codeSent) setState(() => _codeSent = false);
                          _refresh(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      SendCodeButton(
                        label: _codeSent
                            ? 'Reenviar código al correo'
                            : 'Enviar código al correo',
                        icon: Icons.mail_outline,
                        onSend: _sendCode,
                      ),
                      if (_codeSent) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Código enviado a ${_emailController.text.trim()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Código de 4 dígitos',
                        controller: _codeController,
                        hintText: '0000',
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: ValidatorForm.validateCode,
                        onChanged: _refresh,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Nueva contraseña',
                        controller: _newPasswordController,
                        hintText: 'Mínimo 8 caracteres',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: ValidatorForm.validatePassword,
                        onChanged: _refresh,
                        onFieldSubmitted: (_) {
                          if (_canSubmit && !_isLoading) _saveButton();
                        },
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Guardar nueva clave',
                        onPressed:
                            (_canSubmit && !_isLoading) ? _saveButton : null,
                        isLoading: _isLoading,
                      ),
                    ],
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
