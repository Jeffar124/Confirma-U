import 'package:confirma_u/screens/student_screens/student_home_screen.dart';
import 'package:confirma_u/screens/teacher_screens/teacher_home_screen.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:confirma_u/widgets/role_card.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  static const String routeName = '/select-role';

  @override
  State<StatefulWidget> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: 'Seleccionar perfil'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Selecciona tu perfil para personalizar tu experiencia.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            RoleCard(
              role: UserRole.docente,
              isSelected: _selectedRole == UserRole.docente,
              onTap: () {
                setState(() => _selectedRole = UserRole.docente);
                Navigator.pushNamed(context, TeacherHomeScreen.routeName);
              },
              title: "Soy Docente",
              subtitle: "Crea cursos, inicia clases y revisa reportes.",
              icon: Icons.co_present_outlined,
            ),
            const SizedBox(height: 12),
            RoleCard(
              role: UserRole.estudiante,
              isSelected: _selectedRole == UserRole.estudiante,
              onTap: () {
                setState(() => _selectedRole = UserRole.estudiante);
                Navigator.pushNamed(context, StudentHomeScreen.routeName);
              },
              title: "Soy Estudiante",
              subtitle: "Registra tu asistencia y consulta tu historial.",
              icon: Icons.person,
            ),
          ],
        ),
      ),
    );
  }
}
