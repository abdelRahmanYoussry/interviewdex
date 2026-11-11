import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tracks/presentation/widgets/localized_content_text.dart';
import '../cubits/quiz_cubit.dart';
import '../widgets/quiz_question_view.dart';
import 'quiz_route.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<QuizCubit, QuizState>(
    listenWhen: (_, state) => state is QuizResults,
    listener: (context, state) {
      if (state case QuizResults(:final track, :final quiz, :final result)) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.quizSummary,
          arguments: QuizSummaryRequest(
            track: track,
            quiz: quiz,
            result: result,
          ),
        );
      }
    },
    child: BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final strings = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is QuizRunState
                  ? strings.quickQuiz
                  : strings.quizPickerTitle,
            ),
          ),
          body: SafeArea(
            child: switch (state) {
              QuizLoading() => const Center(child: CircularProgressIndicator()),
              QuizFailure() => _failure(context, strings),
              QuizPicker() => _picker(context, state, strings),
              QuizRunState() => QuizQuestionView(state: state),
              QuizResults() => const SizedBox.shrink(),
            },
          ),
        );
      },
    ),
  );

  Widget _failure(BuildContext context, AppLocalizations strings) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.quizLoadFailure),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: context.read<QuizCubit>().load,
            child: Text(strings.retry),
          ),
        ],
      ),
    ),
  );

  Widget _picker(
    BuildContext context,
    QuizPicker state,
    AppLocalizations strings,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (state.resumeSession case final saved?) ...[
          FilledButton.icon(
            key: const ValueKey('resumeQuiz'),
            onPressed: () => context.read<QuizCubit>().start(resume: saved),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(strings.quizResume),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          key: const ValueKey('quizAllTopics'),
          onPressed: () => context.read<QuizCubit>().start(),
          icon: const Icon(Icons.shuffle_rounded),
          label: Text(strings.quizAllTopics),
        ),
        const SizedBox(height: 16),
        for (final topic in state.availableTopics)
          Card(
            child: ListTile(
              key: ValueKey('quiz-topic-${topic.id}'),
              title: LocalizedContentText(
                topic.name,
                languageCode: languageCode,
                alignToUiStart: true,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.read<QuizCubit>().start(topicId: topic.id),
            ),
          ),
      ],
    );
  }
}
