import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// AppBar personalizada y reutilizable para ConfirmaU.
///
/// Permite configurar el título, subtítulo, navegación,
/// acciones y contenido inferior.
class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.bottom,
    this.backgroundColor = Colors.white,
    this.logo,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;

  final bool showBackButton;
  final List<Widget>? actions;

  final PreferredSizeWidget? bottom;

  /// Permite reemplazar el logo predeterminado.
  final Widget? logo;

  /// Controla si se muestra el logo en la AppBar.
  final bool showLogo;

  final Color backgroundColor;

  /// Altura total de la AppBar, incluyendo el contenido inferior.
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 1));

  Widget _buildLogo() {
    if (!showLogo) return const SizedBox.shrink();

    final Widget logoContent = logo ??
        Image.asset(
          'assets/images/logo_icon.png',
          fit: BoxFit.contain,
        );

    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

      // Navegación
      leading: showBackButton
          ? IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,

      titleSpacing: showBackButton ? 0 : 16,

      // Título, logo y subtítulo
      title: Row(
        children: [
          _buildLogo(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // Acciones personalizadas
      actions: actions,

      // Separador inferior o contenido personalizado
      bottom:
          bottom ??
          const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
    );
  }
}

/// Franja blanca con el texto de ayuda bajo la AppBar.
class AuthSubtitle extends StatelessWidget {
  const AuthSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
