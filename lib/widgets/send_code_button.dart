import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botón blanco "Enviar código". Llama a [onSend]; si retorna `true`,
/// bloquea el botón unos segundos antes de permitir reenviar.
class SendCodeButton extends StatefulWidget {
  const SendCodeButton({
    super.key,
    required this.onSend,
    this.label = 'Enviar código',
    this.icon,
    this.cooldownSeconds = 60,
  });

  final Future<bool> Function() onSend;
  final String label;
  final IconData? icon;
  final int cooldownSeconds;

  @override
  State<SendCodeButton> createState() => _SendCodeButtonState();
}

class _SendCodeButtonState extends State<SendCodeButton> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isSending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    setState(() => _isSending = true);
    final sent = await widget.onSend();
    if (!mounted) return;
    setState(() => _isSending = false);
    if (sent) _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _secondsLeft > 0;
    final text = waiting ? 'Reenviar código en ${_secondsLeft}s' : widget.label;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: (waiting || _isSending) ? null : _handleTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        child: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}
