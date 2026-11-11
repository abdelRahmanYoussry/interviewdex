import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tracks/domain/entities/quiz_item.dart';
import '../../../tracks/presentation/widgets/localized_content_text.dart';
import 'quiz_route.dart';

class QuizSummaryScreen extends StatelessWidget {
  const QuizSummaryScreen({required this.request, super.key});

  final QuizSummaryRequest request;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.quizResults)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: colors.accentSoft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '${request.result.score} / ${request.result.total}',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: colors.ink),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.quizScore(
                              request.result.score,
                              request.result.total,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.quizWrongCount(
                              request.result.wrongAnswers.length,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: colors.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final (index, wrong)
                      in request.result.wrongAnswers.indexed)
                    _WrongAnswerCard(
                      key: ValueKey('wrong-${wrong.item.id}-$index'),
                      item: wrong.item,
                      chosenAnswer: wrong.chosenAnswer,
                      languageCode: languageCode,
                      yourAnswer: strings.quizYourAnswer,
                      correctAnswer: strings.quizCorrectAnswer,
                      whyTitle: strings.quizWhy,
                    ),
                  const SizedBox(height: 16),
                  if (request.result.wrongAnswers.isNotEmpty) ...[
                    FilledButton(
                      key: const ValueKey('retryWrongAnswers'),
                      onPressed:
                          () => Navigator.of(context).pushReplacementNamed(
                            AppRoutes.quiz,
                            arguments: QuizRetryRequest(
                              track: request.track,
                              items: [
                                for (final wrong in request.result.wrongAnswers)
                                  wrong.item,
                              ],
                            ),
                          ),
                      child: Text(strings.quizRetryWrong),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton(
                    key: const ValueKey('backToHome'),
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                    child: Text(strings.backToHome),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WrongAnswerCard extends StatelessWidget {
  const _WrongAnswerCard({
    required this.item,
    required this.chosenAnswer,
    required this.languageCode,
    required this.yourAnswer,
    required this.correctAnswer,
    required this.whyTitle,
    super.key,
  });

  final QuizItem item;
  final int chosenAnswer;
  final String languageCode;
  final String yourAnswer;
  final String correctAnswer;
  final String whyTitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final correct = switch (item) {
      MultipleChoiceQuizItem(:final options, :final correctIndex) =>
        options[correctIndex],
      TrueFalseQuizItem() => null,
    };
    final chosen = switch (item) {
      MultipleChoiceQuizItem(:final options) => options[chosenAnswer],
      TrueFalseQuizItem() => null,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LocalizedContentText(
              item.question,
              languageCode: languageCode,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              yourAnswer,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (chosen != null)
              LocalizedContentText(
                chosen,
                languageCode: languageCode,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.ink),
              )
            else
              Text(switch ((item, chosenAnswer)) {
                (TrueFalseQuizItem(), 1) =>
                  AppLocalizations.of(context)!.quizTrue,
                (TrueFalseQuizItem(), 0) =>
                  AppLocalizations.of(context)!.quizFalse,
                _ => '',
              }),
            const SizedBox(height: 12),
            Text(
              correctAnswer,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (correct != null)
              LocalizedContentText(
                correct,
                languageCode: languageCode,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.ink),
              )
            else
              Text(switch (item) {
                TrueFalseQuizItem(answer: true) =>
                  AppLocalizations.of(context)!.quizTrue,
                TrueFalseQuizItem(answer: false) =>
                  AppLocalizations.of(context)!.quizFalse,
                _ => '',
              }),
            const SizedBox(height: 12),
            Text(
              whyTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            LocalizedContentText(
              item.why,
              languageCode: languageCode,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
