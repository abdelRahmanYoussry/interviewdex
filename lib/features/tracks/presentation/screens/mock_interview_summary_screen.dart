import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/mock_interview_summary.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../../domain/entities/track.dart';
import '../cubits/practice_session_cubit.dart';

class MockInterviewSummaryRequest {
  const MockInterviewSummaryRequest({
    required this.track,
    required this.summary,
  });

  final InterviewTrack track;
  final MockInterviewSummary summary;
}

class MockInterviewSummaryScreen extends StatelessWidget {
  const MockInterviewSummaryScreen({
    required this.track,
    required this.summary,
    super.key,
  });

  final InterviewTrack track;
  final MockInterviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final weakIds = summary.weakTopics.map((topic) => topic.topicId).toSet();
    final topics = [
      ...summary.weakTopics,
      for (final topic in summary.topicScores)
        if (!weakIds.contains(topic.topicId)) topic,
    ];
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.mockSummaryTitle)),
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
                          Text(
                            strings.overallScore,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              _percentage(summary.overallScore),
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: colors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    strings.topicBreakdown,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (topics.isEmpty)
                    Text(strings.mockSummaryEmpty)
                  else
                    for (final topic in topics)
                      Card(
                        color:
                            weakIds.contains(topic.topicId)
                                ? colors.accentSoft
                                : colors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      topic.topicName.resolve(languageCode),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        color:
                                            weakIds.contains(topic.topicId)
                                                ? colors.ink
                                                : null,
                                      ),
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      _percentage(topic.score),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        color:
                                            weakIds.contains(topic.topicId)
                                                ? colors.ink
                                                : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (weakIds.contains(topic.topicId)) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: OutlinedButton(
                                    key: ValueKey(
                                      'practice-topic-${topic.topicId}',
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pushNamed(
                                          AppRoutes.practiceSession,
                                          arguments: PracticeSessionRequest(
                                            trackId: track.id,
                                            mode: PracticeMode.topic,
                                            topicId: topic.topicId,
                                          ),
                                        ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colors.ink,
                                    ),
                                    child: Text(strings.practiceThisTopic),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 20),
                  Text(
                    strings.mockReviewCount(summary.reviewCards.length),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final item in summary.reviewCards)
                    Card(
                      child: ListTile(
                        title: Text(
                          item.card.question.question.resolve(languageCode),
                        ),
                        subtitle: Text(
                          item.card.topicName.resolve(languageCode),
                        ),
                        trailing: Text(
                          item.rating == CardRating.missed
                              ? strings.missed
                              : strings.partly,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(strings.backToTrack),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _percentage(double score) => '${(score * 100).round()}%';
}
