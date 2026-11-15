import 'dart:async';

import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/pulse_badge.dart';
import '../../widgets/status_chip.dart';

/// Pantalla "Clase en vivo" (solo visual).
/// El contador de presentes es simulado hasta implementar la verificación real.
class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key, required this.course});
  final CourseModel course;

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  static const String kDemoChallengeEmoji = '🚀';
  late int _remaining = widget.course.minutes * 60;
  int _present = 0;
  int _ticks = 0;
  Timer? _timer;

  bool get _showsEmoji => widget.course.method == 'challenge';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
        _ticks++;
        if (_ticks % 3 == 0 && _present < widget.course.studentCount)
          _present++;
        if (_remaining == 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar asistencia'),
        content: const Text('¿Cerrar el registro de asistencia de esta clase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Finalizar',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        title: 'Clase en vivo',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusChip(
              '● En vivo',
              fg: AppColors.red,
              bg: AppColors.redSoft,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                c.code,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              PulseBadge(
                child: _showsEmoji
                    ? const Text(
                        kDemoChallengeEmoji,
                        style: TextStyle(fontSize: 44),
                      )
                    : const Icon(Icons.sensors, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _showsEmoji
                    ? 'MOSTRANDO EL RETO'
                    : 'TRANSMITIENDO SEÑAL DE CLASE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tiempo restante',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              Text(
                mmss(_remaining),
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: .4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_present / ${c.studentCount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                    const Text(
                      'presentes',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Finalizar asistencia',
                color: AppColors.red,
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
