import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tracks/domain/entities/quiz_item.dart';
import '../../../tracks/domain/value_objects/localized_text.dart';
import '../../../tracks/presentation/widgets/localized_content_text.dart';
import '../cubits/quiz_cubit.dart';
import 'quiz_answer_option.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({required this.state, super.key});

  final QuizRunState state;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final item = state.currentItem;
    final order = state.quiz.optionOrders[item.id] ?? const [0, 1, 2, 3];
    final currentState = state;
    QuizFeedback? feedback;
    if (currentState is QuizFeedback) feedback = currentState;
    final colors = Theme.of(context).extension<AppColors>()!;
    final correctAnswer = switch (item) {
      MultipleChoiceQuizItem(:final correctIndex) => correctIndex,
      TrueFalseQuizItem(:final answer) => answer ? 1 : 0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.quizQuestionProgress(
                  state.index + 1,
                  state.quiz.items.length,
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              LocalizedContentText(
                item.question,
                languageCode: languageCode,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (item.code case final code?) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    code,
                    style: AppTextStyles.code(
                      context,
                    ).copyWith(fontFamily: 'JetBrainsMono'),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (
                var displayedIndex = 0;
                displayedIndex < order.length;
                displayedIndex++
              ) ...[
                if (displayedIndex > 0) const SizedBox(height: 10),
                _option(
                  context: context,
                  item: item,
                  canonicalIndex: order[displayedIndex],
                  displayedIndex: displayedIndex,
                  feedback: feedback,
                  correctAnswer: correctAnswer,
                  strings: strings,
                  languageCode: languageCode,
                ),
              ],
              if (feedback != null) ...[
                const SizedBox(height: 18),
                _correctAnswer(
                  context: context,
                  item: item,
                  correctAnswer: correctAnswer,
                  strings: strings,
                  languageCode: languageCode,
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _explanation(
                  title: strings.quizWhy,
                  text: item.why,
                  languageCode: languageCode,
                ),
                const SizedBox(height: 12),
                _explanation(
                  title: strings.quizTip,
                  text: item.tip,
                  languageCode: languageCode,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const ValueKey('quizNext'),
                  onPressed: context.read<QuizCubit>().next,
                  child: Text(strings.quizNext),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _correctAnswer({
    required BuildContext context,
    required QuizItem item,
    required int correctAnswer,
    required AppLocalizations strings,
    required String languageCode,
    required AppColors colors,
  }) {
    final answer = switch (item) {
      MultipleChoiceQuizItem(:final options) => LocalizedContentText(
        options[correctAnswer],
        languageCode: languageCode,
      ),
      TrueFalseQuizItem() => Text(
        correctAnswer == 1 ? strings.quizTrue : strings.quizFalse,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.goodSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.quizCorrectAnswer,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: TextStyle(color: colors.ink),
            child: answer,
          ),
        ],
      ),
    );
  }

  Widget _option({
    required BuildContext context,
    required QuizItem item,
    required int canonicalIndex,
    required int displayedIndex,
    required QuizFeedback? feedback,
    required int correctAnswer,
    required AppLocalizations strings,
    required String languageCode,
  }) {
    final label = switch (item) {
      MultipleChoiceQuizItem(:final options) => LocalizedContentText(
        options[canonicalIndex],
        languageCode: languageCode,
      ),
      TrueFalseQuizItem() => Text(
        canonicalIndex == 1 ? strings.quizTrue : strings.quizFalse,
        textAlign: TextAlign.start,
      ),
    };
    return QuizAnswerOption(
      key: ValueKey('quiz-option-$displayedIndex'),
      label: label,
      enabled: feedback == null,
      onPressed:
          feedback == null
              ? () => context.read<QuizCubit>().answer(canonicalIndex)
              : null,
      isCorrect: canonicalIndex == correctAnswer,
      isSelected: feedback?.chosenAnswer == canonicalIndex,
      correctLabel: strings.quizCorrect,
      incorrectLabel: strings.quizIncorrect,
    );
  }

  Widget _explanation({
    required String title,
    required LocalizedText text,
    required String languageCode,
  }) => _ExplanationCard(title: title, text: text, languageCode: languageCode);
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.title,
    required this.text,
    required this.languageCode,
  });

  final String title;
  final LocalizedText text;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          LocalizedContentText(
            text,
            languageCode: languageCode,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}
