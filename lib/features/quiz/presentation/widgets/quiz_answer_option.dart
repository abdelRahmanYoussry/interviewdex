import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class QuizAnswerOption extends StatelessWidget {
  const QuizAnswerOption({
    required this.label,
    required this.onPressed,
    required this.enabled,
    required this.isCorrect,
    required this.isSelected,
    required this.correctLabel,
    required this.incorrectLabel,
    super.key,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isCorrect;
  final bool isSelected;
  final String correctLabel;
  final String incorrectLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final answered = !enabled;
    final selectedIncorrect = answered && isSelected && !isCorrect;
    final correctChoice = answered && isCorrect;
    final background =
        correctChoice
            ? colors.goodSoft
            : selectedIncorrect
            ? colors.badSoft
            : colors.surface;
    return Semantics(
      button: enabled,
      selected: isSelected,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: label),
                if (correctChoice || selectedIncorrect) ...[
                  const SizedBox(width: 8),
                  Icon(
                    correctChoice
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: colors.ink,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    correctChoice ? correctLabel : incorrectLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
