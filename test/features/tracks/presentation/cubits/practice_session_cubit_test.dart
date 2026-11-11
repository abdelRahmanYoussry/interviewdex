import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/spaced_repetition.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/practice_session_cubit.dart';

import '../../support/practice_fixtures.dart';

void main() {
  final track = practiceTrack();
  final now = DateTime.utc(2026, 11, 11, 12);

  PracticeSessionCubit createCubit(
    MemoryPracticeProgressRepository progress, {
    TestAnalytics? analytics,
  }) => PracticeSessionCubit(
    loadTracks: LoadTracks(MemoryTrackRepository([track])),
    progressRepository: progress,
    spacedRepetition: const SpacedRepetition(),
    analytics: analytics ?? TestAnalytics(),
    clock: () => now,
  );

  blocTest<PracticeSessionCubit, PracticeSessionState>(
    'emits an active session when a topic is opened',
    build: () => createCubit(MemoryPracticeProgressRepository()),
    act:
        (cubit) => cubit.open(
          const PracticeSessionRequest(
            trackId: 'flutter',
            mode: PracticeMode.topic,
            topicId: 'core',
          ),
        ),
    expect: () => [isA<PracticeSessionLoading>(), isA<PracticeSessionActive>()],
  );

  test(
    'ratings include Nailed it, Partly and Missed without deleting records',
    () async {
      final progress = MemoryPracticeProgressRepository();
      final cubit = createCubit(progress);
      await cubit.open(
        const PracticeSessionRequest(
          trackId: 'flutter',
          mode: PracticeMode.topic,
          topicId: 'core',
        ),
      );
      await cubit.revealAnswer();
      await cubit.rate(CardRating.nailedIt);
      expect((cubit.state as PracticeSessionActive).index, 1);
      await cubit.revealAnswer();
      await cubit.rate(CardRating.partly);
      expect(cubit.state, isA<PracticeSessionComplete>());
      expect(
        progress.records['flutter']!['intro']!.lastRating,
        CardRating.nailedIt,
      );
      expect(
        progress.records['flutter']!['behavioral']!.lastRating,
        CardRating.partly,
      );
      expect(progress.records['flutter']!.length, 2);
      expect(progress.sessions, isEmpty);
      await cubit.close();
    },
  );

  test(
    'Missed requeues the card in the same session and keeps its due time',
    () async {
      final progress = MemoryPracticeProgressRepository();
      final cubit = createCubit(progress);
      await cubit.open(
        const PracticeSessionRequest(
          trackId: 'flutter',
          mode: PracticeMode.topic,
          topicId: 'core',
        ),
      );
      await cubit.revealAnswer();
      await cubit.rate(CardRating.missed);

      var session = cubit.state as PracticeSessionActive;
      expect(session.cards.map((card) => card.question.id), [
        'intro',
        'behavioral',
        'intro',
      ]);
      expect(session.index, 1);
      expect(
        progress.records['flutter']!['intro']!.dueAt,
        now.add(const Duration(minutes: 10)),
      );

      await cubit.revealAnswer();
      await cubit.rate(CardRating.partly);
      session = cubit.state as PracticeSessionActive;
      expect(session.currentCard.question.id, 'intro');
      await cubit.revealAnswer();
      await cubit.rate(CardRating.missed);
      expect(cubit.state, isA<PracticeSessionComplete>());
      expect(progress.records['flutter']!['intro']!.seen, isTrue);
      await cubit.close();
    },
  );

  test(
    'resume restores exact mode, card order, index and reveal state',
    () async {
      final progress = MemoryPracticeProgressRepository();
      const saved = SavedPracticeSession(
        mode: PracticeMode.mock,
        cardIds: ['behavioral', 'intro', 'technical'],
        index: 1,
        revealed: true,
        retriedCardIds: {'behavioral'},
      );
      final cubit = createCubit(progress);
      await cubit.open(
        const PracticeSessionRequest(
          trackId: 'flutter',
          mode: PracticeMode.topic,
          savedSession: saved,
        ),
      );

      final restored = cubit.state as PracticeSessionActive;
      expect(restored.mode, PracticeMode.mock);
      expect(restored.cards.map((card) => card.question.id), saved.cardIds);
      expect(restored.index, 1);
      expect(restored.revealed, isTrue);
      expect(restored.retriedCardIds, {'behavioral'});
      await cubit.close();
    },
  );

  test('reveal emits state before an analytics future completes', () async {
    final analytics = TestAnalytics()..revealCompleter = Completer<void>();
    final cubit = createCubit(
      MemoryPracticeProgressRepository(),
      analytics: analytics,
    );
    await cubit.open(
      const PracticeSessionRequest(
        trackId: 'flutter',
        mode: PracticeMode.topic,
        topicId: 'core',
      ),
    );

    await cubit.revealAnswer().timeout(const Duration(milliseconds: 100));

    expect((cubit.state as PracticeSessionActive).revealed, isTrue);
    analytics.revealCompleter!.complete();
    await cubit.close();
  });

  test('saves fill-in text without changing unseen status', () async {
    final progress = MemoryPracticeProgressRepository();
    final cubit = createCubit(progress);
    await cubit.open(
      const PracticeSessionRequest(
        trackId: 'flutter',
        mode: PracticeMode.topic,
        topicId: 'core',
      ),
    );
    await cubit.saveTemplateAnswer(
      'behavioral',
      'situation',
      'A production incident',
    );

    final record = progress.records['flutter']!['behavioral']!;
    expect(record.seen, isFalse);
    expect(record.status, CardProgressStatus.notSeen);
    expect(record.templateAnswers['situation'], 'A production incident');
    await cubit.close();
  });

  test('debounces template changes into one persisted save', () async {
    final progress = CountingTemplateRepository();
    final cubit = createCubit(progress);
    await cubit.open(
      const PracticeSessionRequest(
        trackId: 'flutter',
        mode: PracticeMode.topic,
        topicId: 'core',
      ),
    );

    await Future.wait([
      cubit.saveTemplateAnswer('behavioral', 'situation', 'Release'),
      cubit.saveTemplateAnswer('behavioral', 'action', 'Coordinated'),
    ]);

    expect(progress.templateSaveCount, 1);
    expect(progress.records['flutter']!['behavioral']!.templateAnswers, {
      'situation': 'Release',
      'action': 'Coordinated',
    });
    await cubit.close();
  });

  test('template persistence failure does not end the session', () async {
    final cubit = createCubit(FailingTemplateRepository());
    await cubit.open(
      const PracticeSessionRequest(
        trackId: 'flutter',
        mode: PracticeMode.topic,
        topicId: 'core',
      ),
    );

    await cubit.saveTemplateAnswer(
      'behavioral',
      'situation',
      'A production incident',
    );

    expect(cubit.state, isA<PracticeSessionActive>());
    await cubit.close();
  });

  test('stale resume data is cleared and a fresh queue is opened', () async {
    final progress =
        MemoryPracticeProgressRepository()
          ..sessions['flutter'] = const SavedPracticeSession(
            mode: PracticeMode.topic,
            cardIds: ['removed-card'],
            index: 0,
            revealed: false,
          );
    final cubit = createCubit(progress);

    await cubit.open(
      const PracticeSessionRequest(
        trackId: 'flutter',
        mode: PracticeMode.topic,
        topicId: 'core',
        savedSession: SavedPracticeSession(
          mode: PracticeMode.topic,
          cardIds: ['removed-card'],
          index: 0,
          revealed: false,
        ),
      ),
    );

    expect(cubit.state, isA<PracticeSessionActive>());
    expect(
      (cubit.state as PracticeSessionActive).currentCard.question.id,
      'intro',
    );
    expect(progress.sessions['flutter']!.cardIds, ['intro', 'behavioral']);
    await cubit.close();
  });
}

class CountingTemplateRepository extends MemoryPracticeProgressRepository {
  int templateSaveCount = 0;

  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) async {
    templateSaveCount += 1;
    await super.saveTemplateAnswers(trackId, cardId, answers);
  }
}

class FailingTemplateRepository extends MemoryPracticeProgressRepository {
  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) async {
    throw StateError('Storage unavailable');
  }
}
