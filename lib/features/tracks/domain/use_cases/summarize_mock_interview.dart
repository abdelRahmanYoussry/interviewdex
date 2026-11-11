import '../entities/card_progress.dart';
import '../entities/mock_interview_summary.dart';
import '../entities/practice_card.dart';
import '../entities/track.dart';

class SummarizeMockInterview {
  const SummarizeMockInterview();

  MockInterviewSummary call(
    InterviewTrack track,
    Map<String, CardRating> ratings,
  ) {
    const points = {
      CardRating.nailedIt: 1.0,
      CardRating.partly: 0.5,
      CardRating.missed: 0.0,
    };
    final topicCards = <String, List<PracticeCard>>{};
    for (final topic in track.topics) {
      topicCards[topic.id] = [
        for (final question in topic.interviewCards)
          PracticeCard(
            topicId: topic.id,
            topicName: topic.name,
            question: question,
          ),
      ];
    }

    final topicScores = <MockTopicScore>[];
    for (final topic in track.topics) {
      final cards = topicCards[topic.id]!;
      final topicRatings = [
        for (final card in cards)
          if (ratings[card.question.id] case final rating?) rating,
      ];
      if (topicRatings.isEmpty) continue;
      topicScores.add(
        MockTopicScore(
          topicId: topic.id,
          topicName: topic.name,
          score:
              topicRatings.fold<double>(
                0,
                (total, rating) => total + points[rating]!,
              ) /
              topicRatings.length,
          ratingCount: topicRatings.length,
        ),
      );
    }
    final weakTopics =
        topicScores.where((topic) => topic.score < 0.7).toList()
          ..sort((left, right) => left.score.compareTo(right.score));
    final ratedCards = [
      for (final cards in topicCards.values)
        for (final card in cards)
          if (ratings[card.question.id] case final rating?)
            MockRatedCard(card: card, rating: rating),
    ];
    final reviewCards =
        ratedCards
            .where(
              (card) =>
                  card.rating == CardRating.missed ||
                  card.rating == CardRating.partly,
            )
            .toList();
    final totalRatingCount = ratedCards.length;
    final overallScore =
        totalRatingCount == 0
            ? 0.0
            : ratedCards.fold<double>(
                  0,
                  (total, card) => total + points[card.rating]!,
                ) /
                totalRatingCount;

    return MockInterviewSummary(
      overallScore: overallScore,
      topicScores: topicScores,
      weakTopics: weakTopics,
      reviewCards: reviewCards,
    );
  }
}
