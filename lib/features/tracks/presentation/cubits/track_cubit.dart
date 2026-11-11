import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/practice_progress_repository.dart';
import '../../domain/use_cases/load_tracks.dart';

sealed class TrackState {
  const TrackState();
}

final class TrackLoading extends TrackState {
  const TrackLoading();
}

final class TrackPicker extends TrackState {
  const TrackPicker(this.tracks);

  final List<InterviewTrack> tracks;
}

final class TrackDashboard extends TrackState {
  const TrackDashboard({
    required this.track,
    required this.cardProgress,
    required this.resumeSession,
  });

  final InterviewTrack track;
  final Map<String, CardProgress> cardProgress;
  final SavedPracticeSession? resumeSession;
}

final class TrackLoadFailure extends TrackState {
  const TrackLoadFailure();
}

class TrackCubit extends Cubit<TrackState> {
  TrackCubit({
    required LoadTracks loadTracks,
    required PracticeProgressRepository progressRepository,
    required AnalyticsService analytics,
    void Function(String message)? logWarning,
  }) : _loadTracks = loadTracks,
       _progressRepository = progressRepository,
       _analytics = analytics,
       _logWarning = logWarning ?? debugPrint,
       super(const TrackLoading());

  final LoadTracks _loadTracks;
  final PracticeProgressRepository _progressRepository;
  final AnalyticsService _analytics;
  final void Function(String message) _logWarning;

  Future<void> loadTracks() async {
    emit(const TrackLoading());
    try {
      final tracks = await _loadTracks();
      if (tracks.length == 1) {
        await selectTrack(tracks.single);
      } else {
        emit(TrackPicker(tracks));
      }
    } on Exception catch (error) {
      debugPrint('Unable to load interview tracks: $error');
      emit(const TrackLoadFailure());
    }
  }

  Future<void> selectTrack(InterviewTrack track) async {
    emit(const TrackLoading());
    try {
      final progress = await _progressRepository.load(track.id);
      var resumeSession = progress.session;
      final cardsByTopic = {
        for (final topic in track.topics)
          topic.id: {for (final card in topic.interviewCards) card.id},
      };
      final contentCardIds = cardsByTopic.values.expand((ids) => ids).toSet();
      final sessionMatchesContent =
          resumeSession == null ||
          (resumeSession.mode == PracticeMode.mock
                  ? resumeSession.topicId == null
                  : resumeSession.topicId != null &&
                      cardsByTopic.containsKey(resumeSession.topicId) &&
                      resumeSession.cardIds.every(
                        cardsByTopic[resumeSession.topicId]!.contains,
                      )) &&
              resumeSession.cardIds.every(contentCardIds.contains);
      if (resumeSession != null && !sessionMatchesContent) {
        _logWarning(
          'Discarding saved session for "${track.id}" because its cards no longer exist.',
        );
        resumeSession = null;
        try {
          await _progressRepository.clearSession(track.id);
        } on Exception catch (error) {
          _logWarning(
            'Unable to clear stale saved session for "${track.id}": $error',
          );
        }
      }
      unawaited(_analytics.trackOpen(track.id));
      emit(
        TrackDashboard(
          track: track,
          cardProgress: progress.cards,
          resumeSession: resumeSession,
        ),
      );
    } on Exception catch (error) {
      debugPrint('Unable to open interview track "${track.id}": $error');
      emit(const TrackLoadFailure());
    }
  }
}
