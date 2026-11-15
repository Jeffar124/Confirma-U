import 'package:confirma_u/models/user_model.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../common/profile_tab_screen.dart';
import 'history_tab.dart';
import 'student_course_tab.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key, this.user});

  static const String routeName = '/student-home';
  final UserModel? user;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreen();
}

class _StudentHomeScreen extends State<StudentHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final currentUid = AuthService.instance.currentUser?.uid;

    return StreamBuilder<UserModel?>(
      stream: widget.user != null
          ? Stream.value(widget.user)
          : (currentUid != null
              ? UserService.instance.streamUser(currentUid)
              : Stream.value(null)),
      initialData: widget.user,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              StudentCoursesTab(user: user),
              HistoryTab(user: user),
              ProfileTab(user: user),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book, color: AppColors.green),
                label: 'CURSOS',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.history, color: AppColors.green),
                label: 'HISTORIAL',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.green),
                label: 'PERFIL',
              ),
            ],
          ),
        );
      },
    );
  }
}
