import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'auth_exception_handler.dart';
import 'user_service.dart';

/// Resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  const AuthResult._({required this.success, this.errorMessage, this.user});

  factory AuthResult.ok(User user) => AuthResult._(success: true, user: user);

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, errorMessage: message);
}

/// Servicio centralizado de autenticación con Firebase Auth.
///
/// Uso:
/// ```dart
/// final result = await AuthService.instance.signIn(email: email, password: password);
/// if (result.success) { /* navegar */ } else { /* mostrar result.errorMessage */ }
/// ```
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Stream de estado del usuario ────────────────────────────────────────────

  /// Emite [User] cuando está autenticado, o `null` cuando cierra sesión.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado (puede ser `null`).
  User? get currentUser => _auth.currentUser;

  // ── Inicio de sesión ────────────────────────────────────────────────────────

  /// Autentica con correo y contraseña.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.ok(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(AuthExceptionHandler.getMessage(e));
    } catch (_) {
      return AuthResult.error('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  // ── Registro ────────────────────────────────────────────────────────────────

  /// Crea una cuenta con correo y contraseña, actualiza el displayName
  /// y guarda el perfil del usuario en Firestore usando [UserModel].
  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
    String? code,
    UserRole role = UserRole.estudiante,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Guardamos el nombre en el perfil del usuario de Auth.
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();

      // Guardamos el perfil en Firestore mediante UserModel.
      final userModel = UserModel(
        uid: credential.user!.uid,
        name: displayName.trim(),
        email: email.trim(),
        code: (code ?? '').trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      await UserService.instance.saveUser(userModel);

      return AuthResult.ok(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(AuthExceptionHandler.getMessage(e));
    } catch (_) {
      return AuthResult.error(
        'Ocurrió un error inesperado al registrar el usuario.',
      );
    }
  }

  // ── Recuperación de contraseña ──────────────────────────────────────────────

  /// Envía un correo de restablecimiento de contraseña al [email] indicado.
  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      // Devolvemos un usuario null porque no hay sesión activa aún.
      return const AuthResult._(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(AuthExceptionHandler.getMessage(e));
    } catch (_) {
      return AuthResult.error('No se pudo enviar el correo. Intenta de nuevo.');
    }
  }

  // ── Cierre de sesión ────────────────────────────────────────────────────────

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
