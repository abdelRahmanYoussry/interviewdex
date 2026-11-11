import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/interview_question.dart';
import '../../domain/value_objects/localized_text.dart';
import 'localized_content_text.dart';

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
        content: question.answer,
        languageCode: languageCode,
      ),
      _AnswerSection(
        title: strings.keyPoints,
        content: LocalizedText({
          for (final language
              in question.keyPoints
                  .expand((point) => point.values.keys)
                  .toSet())
            language: question.keyPoints
                .map((point) => '• ${point.resolve(language)}')
                .join('\n'),
        }),
        languageCode: languageCode,
      ),
      if (question.liveCoding case final liveCoding?) ...[
        _AnswerSection(
          title: strings.solution,
          content: LocalizedText({'en': liveCoding.solution}),
          code: true,
          languageCode: languageCode,
        ),
        _AnswerSection(
          title: strings.steps,
          content: LocalizedText({
            for (final language
                in liveCoding.steps.expand((step) => step.values.keys).toSet())
              language: liveCoding.steps
                  .map((step) => '• ${step.resolve(language)}')
                  .join('\n'),
          }),
          languageCode: languageCode,
        ),
        _AnswerSection(
          title: strings.timeComplexity,
          content: liveCoding.timeComplexity,
          languageCode: languageCode,
        ),
        _AnswerSection(
          title: strings.spaceComplexity,
          content: liveCoding.spaceComplexity,
          languageCode: languageCode,
        ),
      ],
      _AnswerSection(
        title: strings.followUp,
        content: question.followUp,
        languageCode: languageCode,
      ),
      _AnswerSection(
        title: strings.commonMistake,
        content: question.commonMistake,
        languageCode: languageCode,
      ),
    ],
  );
}

class _AnswerSection extends StatelessWidget {
  const _AnswerSection({
    required this.title,
    required this.content,
    required this.languageCode,
    this.code = false,
  });

  final String title;
  final LocalizedText content;
  final String languageCode;
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
          if (code)
            SelectableText(
              content.resolve(languageCode),
              style: AppTextStyles.code(context),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
            )
          else
            LocalizedContentText(
              content,
              languageCode: languageCode,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}
