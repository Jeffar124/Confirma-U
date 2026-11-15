import 'dart:async';

import 'package:confirma_u/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../data/mock_data.dart';
import '../../models/course_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/pulse_badge.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_chip.dart';

enum _Step { searching, detected, challenge, success, failure }

/// Flujo visual de "Decir presente" según el método del curso:
///   ble       -> buscando docente -> detectado -> resultado
///   challenge -> reto rápido -> resultado
///   double    -> paso 1 (buscar) -> paso 2 (reto) -> resultado
/// NO verifica nada de verdad: la búsqueda BLE es simulada con temporizadores
/// y el reto se acepta con [kDemoChallengeEmoji]. No se guarda ninguna asistencia.
class AttendanceFlowScreen extends StatefulWidget {
  const AttendanceFlowScreen({super.key, required this.course});
  final CourseModel course;

  @override
  State<AttendanceFlowScreen> createState() => _AttendanceFlowScreenState();
}

class _AttendanceFlowScreenState extends State<AttendanceFlowScreen> {
  _Step _step = _Step.searching;
  Timer? _timer;
  Timer? _challengeTimer;
  int _seconds = 10;
  DateTime? _doneAt;

  bool get _isDouble => widget.course.method == 'double';
  bool get _isChallenge => widget.course.method == 'challenge';

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    _challengeTimer?.cancel();
  }

  /// Asigna el estado inicial (se puede llamar dentro de setState).
  void _start() {
    _cancel();
    if (_isChallenge) {
      _goChallenge();
      return;
    }
    _step = _Step.searching;
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _step = _Step.detected);
      if (!_isDouble) {
        _timer = Timer(const Duration(milliseconds: 1500), _succeed);
      }
    });
  }

  void _goChallenge() {
    _challengeTimer?.cancel();
    _step = _Step.challenge;
    _seconds = 10;
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_seconds <= 1) {
        t.cancel();
        _fail();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _succeed() {
    _cancel();
    if (!mounted) return;
    setState(() {
      _doneAt = DateTime.now();
      _step = _Step.success;
    });
  }

  void _fail() {
    _cancel();
    if (!mounted) return;
    setState(() => _step = _Step.failure);
  }

  void _pick(String emoji) {
    if (emoji == kDemoChallengeEmoji) {
      _succeed();
    } else {
      _fail();
    }
  }

  String get _title {
    switch (_step) {
      case _Step.searching:
      case _Step.detected:
        return 'Validar asistencia';
      case _Step.challenge:
        return 'Reto rápido';
      case _Step.success:
      case _Step.failure:
        return 'Resultado de asistencia';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(title: _title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            _Step.searching => _searching(),
            _Step.detected => _detected(),
            _Step.challenge => _challenge(),
            _Step.success => _success(),
            _Step.failure => _failure(),
          },
        ),
      ),
    );
  }

  Widget _stepLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.green,
      ),
    ),
  );

  Widget _centered({
    required Widget icon,
    required String title,
    required String subtitle,
    String? step,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(height: 24),
        if (step != null) _stepLabel(step),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _searching() {
    return Column(
      children: [
        Expanded(
          child: _centered(
            step: _isDouble ? 'PASO 1 DE 2' : null,
            icon: const PulseBadge(
              child: Icon(Icons.sensors, size: 40, color: Colors.white),
            ),
            title: 'Buscando al docente…',
            subtitle:
                'Mantén el Bluetooth encendido y permanece cerca del salón.',
          ),
        ),
        if (_isDouble) const PrimaryButton(label: 'Buscando…', onPressed: null),
      ],
    );
  }

  Widget _detected() {
    return Column(
      children: [
        Expanded(
          child: _centered(
            step: _isDouble ? 'PASO 1 DE 2' : null,
            icon: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.desktop_windows_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
            title: '¡Docente detectado!',
            subtitle: 'Encontramos el dispositivo de tu docente en el aula.',
          ),
        ),
        if (_isDouble)
          PrimaryButton(
            label: 'Continuar al reto',
            onPressed: () => setState(_goChallenge),
          ),
      ],
    );
  }

  Widget _challenge() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.green, width: 2),
                        ),
                        child: Text(
                          '$_seconds',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _stepLabel(
                      _isDouble ? 'PASO 2 DE 2' : 'RETO DE ASISTENCIA',
                    ),
                    const Text(
                      'Elige el emoji del tablero',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mira la pantalla del aula y toca la opción correcta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final e in kChallengeEmojis)
                          AppCard(
                            onTap: () => _pick(e),
                            padding: EdgeInsets.zero,
                            child: Center(
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 38),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Solo tienes un intento. El reto cambia en cada clase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _success() {
    final c = widget.course;
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.greenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                '¡Asistencia registrada!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Hoy, ${timeLabel(_doneAt ?? DateTime.now())}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              StatusChip.attendance('Presente'),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InfoRow(Icons.place_outlined, c.room),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        PrimaryButton(
          label: 'Volver al inicio',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _failure() {
    return Column(
      children: [
        Expanded(
          child: _centered(
            icon: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.redSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 52,
                color: AppColors.red,
              ),
            ),
            title: 'No se pudo registrar',
            subtitle: 'No estás cerca del salón o elegiste otro emoji.',
          ),
        ),
        PrimaryButton(label: 'Reintentar', onPressed: () => setState(_start)),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Volver al inicio',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
