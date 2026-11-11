import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../cubits/practice_session_cubit.dart';
import 'mock_interview_summary_screen.dart';
import '../widgets/answer_timer_button.dart';
import '../widgets/practice_answer_sections.dart';
import '../widgets/practice_question_card.dart';
import '../widgets/practice_rating_bar.dart';
import '../widgets/template_answer_form.dart';

export '../widgets/answer_timer_button.dart';

class PracticeSessionRoute extends StatefulWidget {
  const PracticeSessionRoute({
    required this.cubit,
    required this.request,
    super.key,
  });

  final PracticeSessionCubit cubit;
  final PracticeSessionRequest request;

  @override
  State<PracticeSessionRoute> createState() => _PracticeSessionRouteState();
}

class _PracticeSessionRouteState extends State<PracticeSessionRoute> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.cubit.open(widget.request));
  }

  @override
  void dispose() {
    widget.cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.cubit,
    child: PracticeSessionScreen(request: widget.request),
  );
}

class PracticeSessionScreen extends StatelessWidget {
  const PracticeSessionScreen({required this.request, super.key});

  final PracticeSessionRequest request;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return BlocConsumer<PracticeSessionCubit, PracticeSessionState>(
      listener: (context, state) {
        if (state case PracticeSessionComplete(
          :final track,
          summary: final summary?,
        )) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.mockSummary,
            arguments: MockInterviewSummaryRequest(
              track: track,
              summary: summary,
            ),
          );
        }
      },
      builder: (context, state) {
        final title = switch (state) {
          PracticeSessionActive(:final mode) =>
            mode == PracticeMode.mock
                ? strings.mockInterview
                : strings.practiceTitle,
          PracticeSessionComplete(:final track) => track.name.resolve(
            Localizations.localeOf(context).languageCode,
          ),
          PracticeSessionLoading() ||
          PracticeSessionFailure() => strings.practiceTitle,
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              tooltip: strings.backToTrack,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: switch (state) {
              PracticeSessionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              PracticeSessionFailure() => _failure(context, strings),
              PracticeSessionActive() => _active(context, state, strings),
              PracticeSessionComplete() => _complete(context, strings),
            },
          ),
        );
      },
    );
  }

  Widget _failure(BuildContext context, AppLocalizations strings) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.practiceLoadFailure),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<PracticeSessionCubit>().open(request),
            child: Text(strings.retry),
          ),
        ],
      ),
    ),
  );

  Widget _active(
    BuildContext context,
    PracticeSessionActive state,
    AppLocalizations strings,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final question = state.currentCard.question;
    final cubit = context.read<PracticeSessionCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.questionProgress(state.index + 1, state.cards.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                state.currentCard.topicName.resolve(languageCode),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if ((state.progress[question.id]?.nailedItStreak ?? 0) > 0) ...[
                const SizedBox(height: 4),
                Text(
                  strings.nailedItStreak(
                    state.progress[question.id]!.nailedItStreak,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              PracticeQuestionCard(
                question: question,
                languageCode: languageCode,
              ),
              if (!state.revealed) ...[
                const SizedBox(height: 12),
                AnswerTimerButton(strings: strings),
                if (question.fillInTemplate case final template?) ...[
                  const SizedBox(height: 12),
                  TemplateAnswerForm(
                    key: ValueKey('${state.currentCard.question.id}-template'),
                    template: template,
                    answers:
                        state.progress[question.id]?.templateAnswers ??
                        const {},
                    languageCode: languageCode,
                    onChanged:
                        (fieldId, value) => cubit.saveTemplateAnswer(
                          question.id,
                          fieldId,
                          value,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: cubit.revealAnswer,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(strings.revealAnswer),
                ),
              ] else ...[
                const SizedBox(height: 12),
                PracticeAnswerSections(
                  question: question,
                  strings: strings,
                  languageCode: languageCode,
                ),
                PracticeRatingBar(strings: strings, onRate: cubit.rate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _complete(BuildContext context, AppLocalizations strings) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).extension<AppColors>()!.accent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            strings.practiceComplete,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(strings.backToTrack),
          ),
        ],
      ),
    ),
  );
}
