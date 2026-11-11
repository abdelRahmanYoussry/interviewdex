import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/interview_question.dart';

class PracticeAnswerSections extends StatelessWidget {
  const PracticeAnswerSections({
    required this.question,
    required this.strings,
    required this.languageCode,
    super.key,
  });

  final InterviewQuestion question;
  final AppLocalizations strings;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _AnswerSection(
        title: strings.sampleAnswer,
        content: question.answer.resolve(languageCode),
      ),
      _AnswerSection(
        title: strings.keyPoints,
        content: question.keyPoints
            .map((point) => '• ${point.resolve(languageCode)}')
            .join('\n'),
      ),
      if (question.liveCoding case final liveCoding?) ...[
        _AnswerSection(
          title: strings.solution,
          content: liveCoding.solution,
          code: true,
        ),
        _AnswerSection(
          title: strings.steps,
          content: liveCoding.steps
              .map((step) => '• ${step.resolve(languageCode)}')
              .join('\n'),
        ),
        _AnswerSection(
          title: strings.timeComplexity,
          content: liveCoding.timeComplexity.resolve(languageCode),
        ),
        _AnswerSection(
          title: strings.spaceComplexity,
          content: liveCoding.spaceComplexity.resolve(languageCode),
        ),
      ],
      _AnswerSection(
        title: strings.followUp,
        content: question.followUp.resolve(languageCode),
      ),
      _AnswerSection(
        title: strings.commonMistake,
        content: question.commonMistake.resolve(languageCode),
      ),
    ],
  );
}

class _AnswerSection extends StatelessWidget {
  const _AnswerSection({
    required this.title,
    required this.content,
    this.code = false,
  });

  final String title;
  final String content;
  final bool code;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          SelectableText(
            content,
            style:
                code
                    ? AppTextStyles.code(context)
                    : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
