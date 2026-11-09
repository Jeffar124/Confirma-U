import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // El router principal escucha el estado de autenticación.
      home: StreamBuilder<User?>(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          // Mientras Firebase resuelve el estado inicial, mostramos un splash.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          // Usuario autenticado → pantalla principal.
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          // Sin sesión → pantalla de login.
          return const LoginScreen();
        },
      ),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        RecoverPasswordScreen.routeName: (_) => const RecoverPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}

/// Pantalla de carga mientras Firebase resuelve el estado de autenticación.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
