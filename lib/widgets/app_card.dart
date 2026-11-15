import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.accent,
    this.onTap,
    this.borderColor,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    Widget content = Padding(padding: padding, child: child);
    if (accent != null) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(child: content),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
