import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PulseBadge extends StatefulWidget {
  const PulseBadge({super.key, required this.child, this.size = 96});
  final Widget child;
  final double size;

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _ring(double t) {
    final d = widget.size + 84 * t;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.green.withValues(alpha: (1 - t) * .16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return SizedBox(
          width: widget.size + 84,
          height: widget.size + 84,
          child: Stack(
            alignment: Alignment.center,
            children: [_ring(_c.value), _ring((_c.value + .5) % 1), child!],
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
