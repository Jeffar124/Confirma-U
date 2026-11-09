import 'package:cloud_functions/cloud_functions.dart';

/// Resultado de una llamada a Cloud Functions.
class CodeResult {
  final bool success;
  final String? errorMessage;

  const CodeResult._({required this.success, this.errorMessage});

  factory CodeResult.ok() => const CodeResult._(success: true);
  factory CodeResult.error(String message) =>
      CodeResult._(success: false, errorMessage: message);
}

/// Servicio para enviar y verificar el código de 4 dígitos
/// que se usa en el flujo de registro de ConfirmaU.
///
/// Las Cloud Functions correspondientes están en `functions/index.js`.
class VerificationService {
  VerificationService._();

  static final VerificationService instance = VerificationService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ── Envío del código ─────────────────────────────────────────────────────────

  /// Llama a la Cloud Function `sendVerificationCode`.
  /// Genera un código aleatorio de 4 dígitos, lo guarda en Firestore
  /// con expiración de 10 minutos y lo envía al [email] indicado.
  Future<CodeResult> sendCode({required String email}) async {
    try {
      final callable = _functions.httpsCallable('sendVerificationCode');
      await callable.call<Map>({'email': email.trim().toLowerCase()});
      return CodeResult.ok();
    } on FirebaseFunctionsException catch (e) {
      return CodeResult.error(_mapError(e));
    } catch (_) {
      return CodeResult.error('No se pudo enviar el código. Intenta de nuevo.');
    }
  }

  // ── Verificación del código ──────────────────────────────────────────────────

  /// Llama a la Cloud Function `verifyCode`.
  /// Comprueba que el [code] coincida con el guardado en Firestore
  /// para el [email], que no haya expirado y que no haya sido usado.
  Future<CodeResult> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyCode');
      await callable.call<Map>({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      });
      return CodeResult.ok();
    } on FirebaseFunctionsException catch (e) {
      return CodeResult.error(_mapError(e));
    } catch (_) {
      return CodeResult.error('No se pudo verificar el código. Intenta de nuevo.');
    }
  }

  // ── Restablecimiento de contraseña con código ─────────────────────────────

  /// Llama a la Cloud Function `resetPasswordWithCode`.
  /// Valida el código de 4 dígitos guardado en Firestore y actualiza
  /// la contraseña del usuario en Firebase Auth sin requerir sesión iniciada.
  Future<CodeResult> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final callable = _functions.httpsCallable('resetPasswordWithCode');
      await callable.call<Map>({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      });
      return CodeResult.ok();
    } on FirebaseFunctionsException catch (e) {
      return CodeResult.error(_mapError(e));
    } catch (_) {
      return CodeResult.error(
        'No se pudo restablecer la contraseña. Intenta de nuevo.',
      );
    }
  }

  // ── Mapeo de errores ─────────────────────────────────────────────────────────

  String _mapError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return e.message ?? 'Datos inválidos.';
      case 'not-found':
        return 'No encontramos un código para este correo. Solicita uno nuevo.';
      case 'already-exists':
        return 'Este código ya fue utilizado. Solicita uno nuevo.';
      case 'deadline-exceeded':
        return 'El código ha expirado. Solicita uno nuevo.';
      case 'unauthenticated':
        return 'Código incorrecto. Verifica e intenta de nuevo.';
      case 'unavailable':
        return 'Servicio temporalmente no disponible. Intenta más tarde.';
      case 'internal':
        return e.message ?? 'Error del servidor. Intenta más tarde.';
      default:
        return e.message ?? 'Ocurrió un error inesperado.';
    }
  }
}
