import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class AnswerTimerButton extends StatefulWidget {
  const AnswerTimerButton({required this.strings, super.key});

  final AppLocalizations strings;

  @override
  State<AnswerTimerButton> createState() => _AnswerTimerButtonState();
}

class _AnswerTimerButtonState extends State<AnswerTimerButton> {
  Timer? _timer;
  int _remainingSeconds = 90;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 90);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString();
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return OutlinedButton.icon(
      onPressed:
          _remainingSeconds == 0
              ? _start
              : _timer == null
              ? _start
              : null,
      icon: const Icon(Icons.timer_outlined),
      label: Text(
        _timer == null || _remainingSeconds == 0
            ? widget.strings.startAnswerTimer
            : '$minutes:$seconds',
      ),
    );
  }
}
