import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/interview_question.dart';
import 'localized_content_text.dart';

class PracticeQuestionCard extends StatelessWidget {
  const PracticeQuestionCard({
    required this.question,
    required this.languageCode,
    super.key,
  });

  final InterviewQuestion question;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).extension<AppColors>()!.surface2,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: LocalizedContentText(
        question.question,
        languageCode: languageCode,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  );
}
