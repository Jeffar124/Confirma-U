import 'package:confirma_u/screens/teacher_screens/teacher_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/user_model.dart';
import 'screens/Auth/login_screen.dart';
import 'screens/Auth/recover_password_screen.dart';
import 'screens/Auth/register_screen.dart';
import 'screens/student_screens/student_home_screen.dart';
import 'screens/teacher_screens/select_role_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConfirmaU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: StreamBuilder<User?>(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          // Mientras Firebase resuelve el estado inicial, mostramos un splash.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          // Usuario autenticado → determinar pantalla según rol.
          if (snapshot.hasData && snapshot.data != null) {
            return _RoleRouter(uid: snapshot.data!.uid);
          }
          // Sin sesión → pantalla de login.
          return const LoginScreen();
        },
      ),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        RecoverPasswordScreen.routeName: (_) => const RecoverPasswordScreen(),
        SelectRoleScreen.routeName: (_) => const SelectRoleScreen(),
        StudentHomeScreen.routeName: (_) => const StudentHomeScreen(),
        TeacherHomeScreen.routeName: (_) => const TeacherHomeScreen(),
      },
    );
  }
}

/// Widget que consulta Firestore para conocer el rol del usuario autenticado
/// y redirige a la pantalla correspondiente.
class _RoleRouter extends StatelessWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: UserService.instance.streamUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          // El documento aún no existe en Firestore (registro en progreso).
          return const _SplashScreen();
        }

        if (user.role == UserRole.docente) {
          return const SelectRoleScreen();
        }

        // Estudiante (valor por defecto).
        return const StudentHomeScreen();
      },
    );
  }
}

/// Pantalla de carga mientras Firebase resuelve el estado de autenticación.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
