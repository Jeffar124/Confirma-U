import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/verification_service.dart';
import '../theme/app_theme.dart';
import '../utils/validator_form.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_card.dart';
import '../widgets/send_code_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/registro';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeyRegister = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  UserRole _selectedRole = UserRole.estudiante;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _codeSent = false; // true una vez que el código fue enviado con éxito

  /// El botón "Crear cuenta" se habilita cuando todos los campos tienen datos.
  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _studentCodeController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _codeController.text.trim().length == 4 &&
      _codeSent; // requiere que el código haya sido enviado

  @override
  void dispose() {
    _nameController.dispose();
    _studentCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _refresh(String _) => setState(() {});

  // ── Envío del código ─────────────────────────────────────────────────────────

  Future<bool> _sendCode() async {
    // Valida que el correo sea válido antes de enviar.
    if (ValidatorForm.validateEmail(_emailController.text) != null) {
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

  // ── Registro ─────────────────────────────────────────────────────────────────

  Future<void> _registerButton() async {
    if (!_formKeyRegister.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Primero verificamos el código contra Firestore.
    final verifyResult = await VerificationService.instance.verifyCode(
      email: _emailController.text,
      code: _codeController.text,
    );

    if (!mounted) return;

    if (!verifyResult.success) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verifyResult.errorMessage ?? 'Código incorrecto.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 2. Si el código es válido, creamos la cuenta en Firebase Auth y guardamos en Firestore.
    final registerResult = await AuthService.instance.register(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text,
      code: _studentCodeController.text,
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (registerResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente! Bienvenido/a.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(registerResult.errorMessage ?? 'Error al crear la cuenta.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Crea tu cuenta'),
      body: Column(
        children: [
          AuthSubtitle(
            _selectedRole == UserRole.estudiante
                ? 'Usa tus datos institucionales para registrarte como estudiante.'
                : 'Usa tus datos institucionales para registrarte como docente.',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKeyRegister,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Selector de Rol ───────────────────────────────────
                      const Text(
                        'Selecciona tu rol',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          RoleCard(
                            role: UserRole.estudiante,
                            isSelected: _selectedRole == UserRole.estudiante,
                            onTap: () {
                              if (_selectedRole != UserRole.estudiante) {
                                setState(() => _selectedRole = UserRole.estudiante);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          RoleCard(
                            role: UserRole.docente,
                            isSelected: _selectedRole == UserRole.docente,
                            onTap: () {
                              if (_selectedRole != UserRole.docente) {
                                setState(() => _selectedRole = UserRole.docente);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Nombre completo',
                        controller: _nameController,
                        hintText: 'Ej. Valentina Ruiz',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: ValidatorForm.validateFullName,
                        onChanged: _refresh,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: _selectedRole == UserRole.estudiante
                            ? 'Código estudiantil'
                            : 'Código docente',
                        controller: _studentCodeController,
                        hintText: _selectedRole == UserRole.estudiante
                            ? 'Ej. 202410284'
                            : 'Ej. 10928374',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) => ValidatorForm.validateInstitutionalCode(
                          v,
                          isTeacher: _selectedRole == UserRole.docente,
                        ),
                        onChanged: _refresh,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Correo institucional',
                        controller: _emailController,
                        hintText: 'nombre@udla.edu.co',
                        fieldKey: _emailFieldKey,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: ValidatorForm.validateEmail,
                        onChanged: (v) {
                          // Si el correo cambia, el código anterior ya no sirve.
                          if (_codeSent) setState(() => _codeSent = false);
                          _refresh(v);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        hintText: 'Mínimo 8 caracteres',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: ValidatorForm.validatePassword,
                        onChanged: _refresh,
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
                      const SizedBox(height: 16),

                      // ── Botón de envío de código ──────────────────────────
                      SendCodeButton(
                        label: _codeSent
                            ? 'Reenviar código al correo'
                            : 'Enviar código al correo',
                        icon: Icons.mail_outline,
                        onSend: _sendCode,
                      ),

                      // Indicador de estado del código enviado
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
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: ValidatorForm.validateCode,
                        onChanged: _refresh,
                        onFieldSubmitted: (_) {
                          if (_canSubmit) _registerButton();
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Crear cuenta',
                        onPressed:
                            (_canSubmit && !_isLoading) ? _registerButton : null,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes una cuenta?',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              LoginScreen.routeName,
                            ),
                            child: const Text('Inicia sesión'),
                          ),
                        ],
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
