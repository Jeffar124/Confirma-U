/// Validaciones centralizadas de los formularios de ConfirmaU.
/// Cada método retorna `null` si el dato es válido o un mensaje de error.
class ValidatorForm {
  ValidatorForm._();

  /// Dominio permitido para el correo institucional.
  static const String institutionalDomain = 'udla.edu.co';

  static final RegExp _emailRegExp = RegExp(
    r'^[A-Za-z0-9._%+-]+@' + RegExp.escape(institutionalDomain) + r'$',
    caseSensitive: false,
  );

  static final RegExp _studentCodeRegExp = RegExp(r'^\d{6,12}$');
  static final RegExp _fourDigitsRegExp = RegExp(r'^\d{4}$');

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo institucional';
    if (!_emailRegExp.hasMatch(email)) {
      return 'Usa tu correo institucional (@$institutionalDomain)';
    }
    return null;
  }

  /// Contraseña al iniciar sesión: solo se exige que no esté vacía.
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    return null;
  }

  /// Contraseña nueva (registro y recuperación): mínimo 8 caracteres.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 8) return 'Debe tener mínimo 8 caracteres';
    return null;
  }

  static String? validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Ingresa tu nombre completo';
    if (name.split(RegExp(r'\s+')).length < 2) {
      return 'Escribe tu nombre y apellido';
    }
    return null;
  }

  static String? validateStudentCode(String? value) =>
      validateInstitutionalCode(value);

  static String? validateInstitutionalCode(
    String? value, {
    bool isTeacher = false,
  }) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return isTeacher
          ? 'Ingresa tu código docente'
          : 'Ingresa tu código estudiantil';
    }
    if (!_studentCodeRegExp.hasMatch(code)) {
      return 'Solo números (entre 6 y 12 dígitos)';
    }
    return null;
  }

  /// Código de verificación de 4 dígitos enviado al correo.
  static String? validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return 'Ingresa el código de 4 dígitos';
    if (!_fourDigitsRegExp.hasMatch(code)) return 'El código tiene 4 dígitos';
    return null;
  }
}
