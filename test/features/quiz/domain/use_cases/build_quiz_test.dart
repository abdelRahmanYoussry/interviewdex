import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/build_quiz.dart';

import '../../support/quiz_fixtures.dart';

void main() {
  const buildQuiz = BuildQuiz();

  test('builds a mixed quiz with at most ten unique items', () {
    final track = quizTrack(itemsPerTopic: 8);
    final quiz = buildQuiz(track, random: Random(7));

    expect(quiz.items, hasLength(10));
    expect(quiz.items.map((item) => item.id).toSet(), hasLength(10));
    expect(quiz.topicId, isNull);
    expect(
      quiz.optionOrders.keys,
      containsAll(quiz.items.map((item) => item.id)),
    );
    expect(
      track.topics
          .where(
            (topic) => topic.quizItems.any(
              (item) => quiz.items.any((selected) => selected.id == item.id),
            ),
          )
          .length,
      greaterThan(1),
    );
  });

  test('builds only the requested topic', () {
    final quiz = buildQuiz(quizTrack(), topicId: 'topic_1', random: Random(2));

    expect(quiz.topicId, 'topic_1');
    expect(
      quiz.items.map((item) => item.id),
      everyElement(startsWith('quiz_1_')),
    );
  });

  test('produces the same order and option shuffles for the same seed', () {
    final track = quizTrack(itemsPerTopic: 6);
    final first = buildQuiz(track, random: Random(19));
    final second = buildQuiz(track, random: Random(19));

    expect(
      first.items.map((item) => item.id).toList(),
      second.items.map((item) => item.id).toList(),
    );
    expect(first.optionOrders, second.optionOrders);
  });

  test('shuffles true-false choices as a deterministic permutation', () {
    final track = quizTrack(
      topicCount: 1,
      itemsPerTopic: 2,
      includeTrueFalse: true,
    );
    final first = buildQuiz(track, random: Random(5));
    final second = buildQuiz(track, random: Random(5));
    final item = track.topics.single.quizItems.last;

    expect(first.optionOrders[item.id], unorderedEquals([0, 1]));
    expect(first.optionOrders[item.id], second.optionOrders[item.id]);
  });

  test('returns an empty result only when no quiz items exist', () {
    final quiz = buildQuiz(quizTrack(topicCount: 0), random: Random(0));

    expect(quiz.items, isEmpty);
  });

  test(
    'returns all available items when content is shorter than the target',
    () {
      final quiz = buildQuiz(
        quizTrack(topicCount: 1, itemsPerTopic: 3),
        random: Random(0),
      );

      expect(quiz.items, hasLength(3));
    },
  );
}
