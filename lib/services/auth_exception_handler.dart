import 'package:firebase_auth/firebase_auth.dart';

/// Convierte un [FirebaseAuthException] en un mensaje legible en español.
class AuthExceptionHandler {
  static String getMessage(FirebaseAuthException e) {
    switch (e.code) {
      // ── Login ─────────────────────────────────────────────────────────
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';

      // ── Registro ───────────────────────────────────────────────────────
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'operation-not-allowed':
        return 'El registro por correo no está habilitado.';

      // ── Recuperación de contraseña ─────────────────────────────────────
      case 'auth/invalid-email':
        return 'El correo ingresado no es válido.';

      // ── Red / genérico ─────────────────────────────────────────────────
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';

      default:
        return 'Ocurrió un error inesperado. Intenta de nuevo.';
    }
  }
}
