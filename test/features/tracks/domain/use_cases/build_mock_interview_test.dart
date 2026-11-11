import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/interview_question.dart';
import 'package:interviewdex/features/tracks/domain/entities/track.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/build_mock_interview.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

void main() {
  const builder = BuildMockInterview();

  test('builds ten unique cards in the required stage order', () {
    final result = builder(
      _track(
        intro: 1,
        behavioral: 2,
        technicalByTopic: const {'a': 4, 'b': 4, 'c': 4},
        liveCoding: 2,
      ),
      const {},
      Random(7),
    );

    expect(result, hasLength(10));
    expect(result.map((card) => card.question.id).toSet(), hasLength(10));
    expect(result.map((card) => card.question.stage), [
      InterviewStage.intro,
      InterviewStage.behavioral,
      InterviewStage.behavioral,
      ...List.filled(6, InterviewStage.technical),
      InterviewStage.liveCoding,
    ]);
  });

  test('round robin mixes technical cards across topics', () {
    final result = builder(
      _track(
        intro: 1,
        behavioral: 2,
        technicalByTopic: const {'a': 6, 'b': 6, 'c': 6},
        liveCoding: 1,
      ),
      const {},
      Random(12),
    );
    final technicalTopics = [
      for (final card in result)
        if (card.question.stage == InterviewStage.technical) card.topicId,
    ];

    expect(technicalTopics.toSet(), {'a', 'b', 'c'});
    final counts = {
      for (final topic in technicalTopics.toSet())
        topic: technicalTopics.where((item) => item == topic).length,
    };
    expect(
      counts.values.reduce((a, b) => a > b ? a : b) -
          counts.values.reduce((a, b) => a < b ? a : b),
      lessThanOrEqualTo(1),
    );
  });

  test('prefers unmastered technical cards over mastered cards', () {
    final track = _track(
      intro: 1,
      behavioral: 2,
      technicalByTopic: const {'a': 9},
      liveCoding: 1,
    );
    final mastered = {
      for (var i = 0; i < 8; i++)
        'a-technical-$i': CardProgress(
          seen: true,
          lastRating: CardRating.nailedIt,
          nailedItStreak: 2,
          intervalDays: 7,
          dueAt: DateTime.utc(2027),
        ),
    };
    mastered.remove('a-technical-7');

    final result = builder(track, mastered, Random(3));
    final technicalIds = {
      for (final card in result)
        if (card.question.stage == InterviewStage.technical) card.question.id,
    };

    expect(technicalIds, contains('a-technical-7'));
  });

  test('fills a missing intro and behavioral slots with technical cards', () {
    final result = builder(
      _track(
        intro: 0,
        behavioral: 0,
        technicalByTopic: const {'a': 9},
        liveCoding: 1,
      ),
      const {},
      Random(1),
    );

    expect(result, hasLength(10));
    expect(
      result
          .take(9)
          .every((card) => card.question.stage == InterviewStage.technical),
      isTrue,
    );
    expect(result.last.question.stage, InterviewStage.liveCoding);
  });

  test('fills only the missing behavioral slots from technical cards', () {
    final result = builder(
      _track(
        intro: 1,
        behavioral: 0,
        technicalByTopic: const {'a': 8},
        liveCoding: 1,
      ),
      const {},
      Random(6),
    );

    expect(result, hasLength(10));
    expect(result.first.question.stage, InterviewStage.intro);
    expect(
      result
          .skip(1)
          .take(8)
          .every((card) => card.question.stage == InterviewStage.technical),
      isTrue,
    );
    expect(result.last.question.stage, InterviewStage.liveCoding);
  });

  test('uses the available live coding card last and omits it when absent', () {
    final withLive = builder(
      _track(
        intro: 1,
        behavioral: 1,
        technicalByTopic: const {'a': 2},
        liveCoding: 1,
      ),
      const {},
      Random(2),
    );
    final withoutLive = builder(
      _track(
        intro: 1,
        behavioral: 1,
        technicalByTopic: const {'a': 2},
        liveCoding: 0,
      ),
      const {},
      Random(2),
    );

    expect(withLive.last.question.stage, InterviewStage.liveCoding);
    expect(
      withoutLive.every(
        (card) => card.question.stage != InterviewStage.liveCoding,
      ),
      isTrue,
    );
  });

  test(
    'degrades gracefully with short content and returns empty only if empty',
    () {
      final shortTrack = _track(
        intro: 1,
        behavioral: 1,
        technicalByTopic: const {'a': 1},
        liveCoding: 0,
      );
      final shortResult = builder(shortTrack, const {}, Random(5));

      expect(shortResult, hasLength(3));
      expect(builder(_track(), const {}, Random(1)), isEmpty);
      expect(builder(_track(behavioral: 2), const {}, Random(1)), hasLength(2));
    },
  );

  test('same seed returns the same card order', () {
    final track = _track(
      intro: 2,
      behavioral: 4,
      technicalByTopic: const {'a': 8, 'b': 8, 'c': 8},
      liveCoding: 2,
    );

    final first = builder(track, const {}, Random(91));
    final second = builder(track, const {}, Random(91));

    expect(
      first.map((card) => card.question.id).toList(),
      second.map((card) => card.question.id).toList(),
    );
  });
}

InterviewTrack _track({
  int intro = 0,
  int behavioral = 0,
  Map<String, int> technicalByTopic = const {},
  int liveCoding = 0,
}) {
  final topics = <InterviewTopic>[];
  void addTopic(String id, List<InterviewQuestion> cards) {
    topics.add(InterviewTopic(id: id, name: _text(id), interviewCards: cards));
  }

  if (intro + behavioral + liveCoding > 0) {
    addTopic('opening', [
      for (var i = 0; i < intro; i++)
        _question('opening-intro-$i', InterviewStage.intro),
      for (var i = 0; i < behavioral; i++)
        _question('opening-behavioral-$i', InterviewStage.behavioral),
      for (var i = 0; i < liveCoding; i++)
        _question('opening-live-$i', InterviewStage.liveCoding),
    ]);
  }
  for (final entry in technicalByTopic.entries) {
    addTopic(entry.key, [
      for (var i = 0; i < entry.value; i++)
        _question('${entry.key}-technical-$i', InterviewStage.technical),
    ]);
  }
  return InterviewTrack(
    id: 'test',
    name: _text('Test'),
    description: _text('Test track'),
    icon: 'icon.png',
    topics: topics,
  );
}

InterviewQuestion _question(String id, InterviewStage stage) {
  final text = _text(id);
  return InterviewQuestion(
    id: id,
    stage: stage,
    difficulty: QuestionDifficulty.junior,
    source: 'Reason: test',
    question: text,
    keyPoints: [text],
    answer: text,
    followUp: text,
    commonMistake: text,
  );
}

LocalizedText _text(String text) => LocalizedText({'en': text, 'ar': text});
