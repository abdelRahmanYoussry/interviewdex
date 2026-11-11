import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../../domain/entities/track.dart';
import '../cubits/practice_session_cubit.dart';
import '../cubits/track_cubit.dart';
import '../widgets/localized_content_text.dart';

class TrackRoute extends StatefulWidget {
  const TrackRoute({required this.cubit, super.key});

  final TrackCubit cubit;

  @override
  State<TrackRoute> createState() => _TrackRouteState();
}

class _TrackRouteState extends State<TrackRoute> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.cubit.loadTracks());
  }

  @override
  void dispose() {
    widget.cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: widget.cubit, child: const TrackScreen());
}

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return BlocBuilder<TrackCubit, TrackState>(
      builder: (context, state) {
        final title = switch (state) {
          TrackDashboard(:final track) => LocalizedContentText(
            track.name,
            languageCode: Localizations.localeOf(context).languageCode,
            alignToUiStart: true,
          ),
          TrackPicker() => Text(strings.trackPickerTitle),
          TrackLoading() || TrackLoadFailure() => Text(strings.startInterview),
        };
        return Scaffold(
          appBar: AppBar(title: title),
          body: SafeArea(
            child: switch (state) {
              TrackLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TrackLoadFailure() => _failure(context, strings),
              TrackPicker(:final tracks) => _picker(context, tracks, strings),
              TrackDashboard() => _dashboard(context, state, strings),
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
          Text(strings.trackLoadFailure),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: context.read<TrackCubit>().loadTracks,
            child: Text(strings.retry),
          ),
        ],
      ),
    ),
  );

  Widget _picker(
    BuildContext context,
    List<InterviewTrack> tracks,
    AppLocalizations strings,
  ) {
    if (tracks.isEmpty) return Center(child: Text(strings.noTracksAvailable));
    final languageCode = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.chooseTrack, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final track in tracks)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                16,
                10,
                12,
                10,
              ),
              leading: ImageIcon(
                AssetImage(track.icon),
                color: Theme.of(context).extension<AppColors>()!.accent,
                size: 32,
              ),
              title: LocalizedContentText(
                track.name,
                languageCode: languageCode,
                alignToUiStart: true,
              ),
              subtitle: LocalizedContentText(
                track.description,
                languageCode: languageCode,
              ),
              onTap: () => context.read<TrackCubit>().selectTrack(track),
            ),
          ),
      ],
    );
  }

  Widget _dashboard(
    BuildContext context,
    TrackDashboard state,
    AppLocalizations strings,
  ) {
    final track = state.track;
    final languageCode = Localizations.localeOf(context).languageCode;
    final allCards = [
      for (final topic in track.topics) ...topic.interviewCards,
    ];
    final mastered =
        allCards
            .where(
              (card) =>
                  state.cardProgress[card.id]?.status ==
                  CardProgressStatus.mastered,
            )
            .length;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageIcon(
                    AssetImage(track.icon),
                    color: Theme.of(context).extension<AppColors>()!.accent,
                    size: 36,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedContentText(
                          track.name,
                          languageCode: languageCode,
                          alignToUiStart: true,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        LocalizedContentText(
                          track.description,
                          languageCode: languageCode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                strings.masteryProgress(mastered, allCards.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (state.resumeSession case final saved?) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).extension<AppColors>()!.accentSoft,
                  child: ListTile(
                    title: Text(
                      saved.mode == PracticeMode.mock
                          ? strings.resumeMockInterview
                          : strings.resumePractice,
                    ),
                    subtitle: Text(
                      strings.questionProgress(
                        saved.index + 1,
                        saved.cardIds.length,
                      ),
                    ),
                    trailing: const Icon(Icons.play_arrow_rounded),
                    onTap:
                        () => _openSession(
                          context,
                          track.id,
                          mode: saved.mode,
                          savedSession: saved,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  _openSession(context, track.id, mode: PracticeMode.mock);
                },
                icon: const Icon(Icons.record_voice_over_outlined),
                label: Text(strings.startMockInterview),
              ),
              const SizedBox(height: 20),
              Text(
                strings.topics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final topic in track.topics)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LocalizedContentText(
                          topic.name,
                          languageCode: languageCode,
                          alignToUiStart: true,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.topicCardCount(topic.interviewCards.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton(
                            key: ValueKey('practice-${topic.id}'),
                            onPressed:
                                () => _openSession(
                                  context,
                                  track.id,
                                  mode: PracticeMode.topic,
                                  topicId: topic.id,
                                ),
                            child: Text(strings.practiceTopic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSession(
    BuildContext context,
    String trackId, {
    required PracticeMode mode,
    String? topicId,
    SavedPracticeSession? savedSession,
  }) {
    final cubit = context.read<TrackCubit>();
    Navigator.of(context)
        .pushNamed(
          AppRoutes.practiceSession,
          arguments: PracticeSessionRequest(
            trackId: trackId,
            mode: mode,
            topicId: topicId,
            savedSession: savedSession,
          ),
        )
        .then((_) {
          final state = cubit.state;
          if (state is TrackDashboard) {
            unawaited(cubit.selectTrack(state.track));
          }
        });
  }
}
