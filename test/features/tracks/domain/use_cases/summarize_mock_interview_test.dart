import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/interview_question.dart';
import 'package:interviewdex/features/tracks/domain/entities/track.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/summarize_mock_interview.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

import '../../support/practice_fixtures.dart';

void main() {
  const summarize = SummarizeMockInterview();
  final track = practiceTrack();

  test('calculates topic and overall scores and weak topics in order', () {
    final summary = summarize(track, const {
      'intro': CardRating.missed,
      'behavioral': CardRating.missed,
      'technical': CardRating.partly,
    });

    expect(summary.overallScore, closeTo(1 / 6, 0.0001));
    expect(summary.topicScores, hasLength(2));
    expect(summary.weakTopics.map((topic) => topic.topicId), [
      'core',
      'technical',
    ]);
    expect(summary.topicScores.first.score, 0);
    expect(summary.reviewCards, hasLength(3));
  });

  test('topic scores below 70 percent are weak', () {
    final trackWithTopics = practiceTrack();
    final summary = summarize(trackWithTopics, const {
      'intro': CardRating.missed,
      'behavioral': CardRating.partly,
      'technical': CardRating.nailedIt,
    });

    expect(summary.weakTopics.map((topic) => topic.topicId), ['core']);
    expect(summary.weakTopics.single.score, 0.25);
  });

  test('a topic score of exactly 70 percent is not weak', () {
    final topic = InterviewTopic(
      id: 'threshold',
      name: LocalizedText({'en': 'Threshold', 'ar': 'حد'}),
      interviewCards: [
        for (var index = 0; index < 10; index++) _question('threshold-$index'),
      ],
    );
    final thresholdTrack = InterviewTrack(
      id: 'threshold-track',
      name: LocalizedText({'en': 'Threshold', 'ar': 'حد'}),
      description: LocalizedText({'en': 'Track', 'ar': 'مسار'}),
      icon: 'icon.png',
      topics: [topic],
    );
    final ratings = {
      for (var index = 0; index < 7; index++)
        'threshold-$index': CardRating.nailedIt,
      for (var index = 7; index < 10; index++)
        'threshold-$index': CardRating.missed,
    };

    final summary = summarize(thresholdTrack, ratings);

    expect(summary.topicScores.single.score, 0.7);
    expect(summary.weakTopics, isEmpty);
  });

  test(
    'empty ratings yield zero overall score and no topics or weak topics',
    () {
      final summary = summarize(track, const {});

      expect(summary.overallScore, 0);
      expect(summary.topicScores, isEmpty);
      expect(summary.weakTopics, isEmpty);
      expect(summary.reviewCards, isEmpty);
    },
  );

  test(
    'all perfect ratings score 100 percent with no weak or review cards',
    () {
      final summary = summarize(track, const {
        'intro': CardRating.nailedIt,
        'behavioral': CardRating.nailedIt,
        'technical': CardRating.nailedIt,
        'technical-two': CardRating.nailedIt,
      });

      expect(summary.overallScore, 1);
      expect(summary.weakTopics, isEmpty);
      expect(summary.reviewCards, isEmpty);
    },
  );
}

InterviewQuestion _question(String id) {
  final text = LocalizedText({'en': id, 'ar': id});
  return InterviewQuestion(
    id: id,
    stage: InterviewStage.technical,
    difficulty: QuestionDifficulty.junior,
    source: 'Reason: test',
    question: text,
    keyPoints: [text],
    answer: text,
    followUp: text,
    commonMistake: text,
  );
}
