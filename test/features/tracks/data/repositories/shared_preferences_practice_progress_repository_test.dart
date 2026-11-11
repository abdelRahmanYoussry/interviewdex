import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/data/repositories/shared_preferences_practice_progress_repository.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/repositories/practice_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'stores versioned progress, ratings, sessions, and template answers',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesPracticeProgressRepository(
        preferences,
      );
      final dueAt = DateTime.utc(2026, 11, 12);
      final session = SavedPracticeSession(
        mode: PracticeMode.topic,
        topicId: 'behavioral',
        cardIds: const ['card-a', 'card-b'],
        index: 1,
        revealed: true,
      );

      await repository.saveTemplateAnswers('flutter', 'card-a', {
        'situation': 'Release deadline',
      });
      await repository.saveCard(
        'flutter',
        'card-a',
        CardProgress(
          seen: true,
          lastRating: CardRating.partly,
          nailedItStreak: 0,
          intervalDays: 1,
          dueAt: dueAt,
          templateAnswers: const {'situation': 'Release deadline'},
        ),
      );
      await repository.saveSession('flutter', session);
      await repository.saveCard(
        'flutter',
        'card-b',
        CardProgress(
          seen: true,
          lastRating: CardRating.missed,
          nailedItStreak: 0,
          intervalDays: 0,
          dueAt: dueAt.add(const Duration(minutes: 10)),
        ),
      );

      expect(preferences.getKeys(), {'practice.v1.flutter'});
      final stored = jsonDecode(preferences.getString('practice.v1.flutter')!);
      expect(stored['version'], 1);
      final loaded = await repository.load('flutter');
      expect(loaded.session, session);
      expect(loaded.cards['card-a']!.lastRating, CardRating.partly);
      expect(loaded.cards['card-a']!.templateAnswers, {
        'situation': 'Release deadline',
      });
      expect(loaded.cards['card-b']!.lastRating, CardRating.missed);
    },
  );

  test('clearing a session preserves seen card records', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesPracticeProgressRepository(preferences);
    final progress = CardProgress(
      seen: true,
      lastRating: CardRating.missed,
      nailedItStreak: 0,
      intervalDays: 0,
      dueAt: DateTime.utc(2026, 11, 11, 12, 10),
    );
    await repository.saveCard('flutter', 'seen-card', progress);
    await repository.saveSession(
      'flutter',
      const SavedPracticeSession(
        mode: PracticeMode.mock,
        cardIds: ['seen-card'],
        index: 0,
        revealed: false,
      ),
    );

    await repository.clearSession('flutter');

    final loaded = await repository.load('flutter');
    expect(loaded.session, isNull);
    expect(loaded.cards['seen-card'], progress);
  });

  test('rejects unsupported progress versions', () async {
    SharedPreferences.setMockInitialValues({
      'practice.v1.flutter': '{"version": 2, "cards": {}, "session": null}',
    });
    final warnings = <String>[];
    final repository = SharedPreferencesPracticeProgressRepository(
      await SharedPreferences.getInstance(),
      logWarning: warnings.add,
    );

    expect(await repository.load('flutter'), const PracticeProgress(cards: {}));
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('practice.v1.flutter.backup'),
      '{"version": 2, "cards": {}, "session": null}',
    );
    expect(warnings, hasLength(1));
  });

  test('backs up unreadable JSON and returns empty progress', () async {
    SharedPreferences.setMockInitialValues({
      'practice.v1.flutter': '{"version":',
    });
    final warnings = <String>[];
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesPracticeProgressRepository(
      preferences,
      logWarning: warnings.add,
    );

    expect(await repository.load('flutter'), const PracticeProgress(cards: {}));
    expect(preferences.getString('practice.v1.flutter.backup'), '{"version":');
    expect(warnings, hasLength(1));
  });

  test('skips invalid card records while retaining valid records', () async {
    SharedPreferences.setMockInitialValues({
      'practice.v1.flutter': jsonEncode({
        'version': 1,
        'cards': {
          'good': {
            'seen': true,
            'lastRating': 'partly',
            'nailedItStreak': 0,
            'intervalDays': 1,
            'dueAt': '2026-11-12T12:00:00Z',
            'templateAnswers': {'situation': 'Release'},
          },
          'bad': {
            'seen': 'yes',
            'lastRating': 'invalid',
            'nailedItStreak': 0,
            'intervalDays': 1,
            'dueAt': 'not-a-date',
            'templateAnswers': {},
          },
        },
        'session': null,
      }),
    });
    final warnings = <String>[];
    final repository = SharedPreferencesPracticeProgressRepository(
      await SharedPreferences.getInstance(),
      logWarning: warnings.add,
    );

    final progress = await repository.load('flutter');

    expect(progress.cards.keys, {'good'});
    expect(progress.cards['good']!.seen, isTrue);
    expect(warnings, hasLength(1));
  });

  test('discards a session containing non-string card ids safely', () async {
    SharedPreferences.setMockInitialValues({
      'practice.v1.flutter': jsonEncode({
        'version': 1,
        'cards': {},
        'session': {
          'mode': 'topic',
          'cardIds': ['card-a', 42],
          'index': 0,
          'revealed': false,
        },
      }),
    });
    final warnings = <String>[];
    final repository = SharedPreferencesPracticeProgressRepository(
      await SharedPreferences.getInstance(),
      logWarning: warnings.add,
    );

    final progress = await repository.load('flutter');

    expect(progress.session, isNull);
    expect(warnings, hasLength(1));
  });

  test('serializes overlapping record, template, and session writes', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesPracticeProgressRepository(
      await SharedPreferences.getInstance(),
    );
    final progress = CardProgress(
      seen: true,
      lastRating: CardRating.nailedIt,
      nailedItStreak: 1,
      intervalDays: 3,
      dueAt: DateTime.utc(2026, 11, 14),
    );

    await Future.wait([
      repository.saveTemplateAnswers('flutter', 'card-a', {
        'situation': 'Release',
      }),
      repository.saveCard('flutter', 'card-a', progress),
      repository.saveSession(
        'flutter',
        const SavedPracticeSession(
          mode: PracticeMode.topic,
          cardIds: ['card-a'],
          index: 0,
          revealed: false,
        ),
      ),
    ]);

    final stored = await repository.load('flutter');
    expect(stored.cards['card-a']!.lastRating, CardRating.nailedIt);
    expect(stored.cards['card-a']!.templateAnswers, {'situation': 'Release'});
    expect(stored.session!.cardIds, ['card-a']);
  });

  test('normalizes stored and newly saved due dates to UTC', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesPracticeProgressRepository(
      await SharedPreferences.getInstance(),
    );
    final localDueAt = DateTime(2026, 11, 12, 12);
    await repository.saveCard(
      'flutter',
      'card-a',
      CardProgress(
        seen: true,
        lastRating: CardRating.partly,
        nailedItStreak: 0,
        intervalDays: 1,
        dueAt: localDueAt,
      ),
    );

    final loaded = await repository.load('flutter');
    expect(loaded.cards['card-a']!.dueAt!.isUtc, isTrue);
  });
}
