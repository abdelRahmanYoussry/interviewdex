import 'package:equatable/equatable.dart';

import 'card_progress.dart';
import 'practice_card.dart';
import '../value_objects/localized_text.dart';

class MockTopicScore extends Equatable {
  const MockTopicScore({
    required this.topicId,
    required this.topicName,
    required this.score,
    required this.ratingCount,
  });

  final String topicId;
  final LocalizedText topicName;
  final double score;
  final int ratingCount;

  @override
  List<Object> get props => [topicId, topicName, score, ratingCount];
}

class MockRatedCard extends Equatable {
  const MockRatedCard({required this.card, required this.rating});

  final PracticeCard card;
  final CardRating rating;

  @override
  List<Object> get props => [card, rating];
}

class MockInterviewSummary extends Equatable {
  const MockInterviewSummary({
    required this.overallScore,
    required this.topicScores,
    required this.weakTopics,
    required this.reviewCards,
  });

  final double overallScore;
  final List<MockTopicScore> topicScores;
  final List<MockTopicScore> weakTopics;
  final List<MockRatedCard> reviewCards;

  @override
  List<Object> get props => [
    overallScore,
    topicScores,
    weakTopics,
    reviewCards,
  ];
}
