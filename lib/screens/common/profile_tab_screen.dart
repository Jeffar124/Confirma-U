import 'package:confirma_u/models/user_model.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Perfil"),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _row('Rol', user.role.label),
                if (user.code.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _row('Código', user.code),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Cerrar sesión',
            color: AppColors.red,
            onPressed: () => AuthService.instance.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ],
  );
}
