import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/track_cubit.dart';

import '../../support/practice_fixtures.dart';

void main() {
  final track = practiceTrack();

  blocTest<TrackCubit, TrackState>(
    'opens the only track directly',
    build:
        () => TrackCubit(
          loadTracks: LoadTracks(MemoryTrackRepository([track])),
          progressRepository: MemoryPracticeProgressRepository(),
          analytics: TestAnalytics(),
        ),
    act: (cubit) => cubit.loadTracks(),
    expect: () => [isA<TrackLoading>(), isA<TrackDashboard>()],
  );

  blocTest<TrackCubit, TrackState>(
    'shows a track picker when more than one track is available',
    build:
        () => TrackCubit(
          loadTracks: LoadTracks(
            MemoryTrackRepository([
              track,
              practiceTrack(id: 'another', name: 'Another'),
            ]),
          ),
          progressRepository: MemoryPracticeProgressRepository(),
          analytics: TestAnalytics(),
        ),
    act: (cubit) => cubit.loadTracks(),
    expect: () => [isA<TrackLoading>(), isA<TrackPicker>()],
  );

  test('track opening does not wait for analytics', () async {
    final analytics = TestAnalytics()..trackOpenCompleter = Completer<void>();
    final cubit = TrackCubit(
      loadTracks: LoadTracks(MemoryTrackRepository([track])),
      progressRepository: MemoryPracticeProgressRepository(),
      analytics: analytics,
    );

    await cubit.loadTracks().timeout(const Duration(milliseconds: 100));

    expect(cubit.state, isA<TrackDashboard>());
    await cubit.close();
  });

  test('stale saved card ids are cleared and not offered for resume', () async {
    final progress =
        MemoryPracticeProgressRepository()
          ..sessions['flutter'] = const SavedPracticeSession(
            mode: PracticeMode.topic,
            cardIds: ['removed-card'],
            index: 0,
            revealed: false,
          );
    final cubit = TrackCubit(
      loadTracks: LoadTracks(MemoryTrackRepository([track])),
      progressRepository: progress,
      analytics: TestAnalytics(),
    );

    await cubit.loadTracks();

    expect((cubit.state as TrackDashboard).resumeSession, isNull);
    expect(progress.sessions, isEmpty);
    await cubit.close();
  });
}
