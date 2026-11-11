import '../entities/card_progress.dart';
import '../entities/interview_question.dart';

class SpacedRepetition {
  const SpacedRepetition();

  static const _nailedItIntervals = [3, 7, 15, 30];

  CardProgress applyRating(
    CardProgress current,
    CardRating rating,
    DateTime now,
  ) {
    final utcNow = now.toUtc();
    final streak =
        rating == CardRating.nailedIt ? current.nailedItStreak + 1 : 0;
    final interval = switch (rating) {
      CardRating.missed => 0,
      CardRating.partly => 1,
      CardRating.nailedIt =>
        _nailedItIntervals[(streak - 1).clamp(
          0,
          _nailedItIntervals.length - 1,
        )],
    };
    final dueAt = switch (rating) {
      CardRating.missed => utcNow.add(const Duration(minutes: 10)),
      CardRating.partly => utcNow.add(const Duration(days: 1)),
      CardRating.nailedIt => utcNow.add(Duration(days: interval)),
    };
    return CardProgress(
      seen: true,
      lastRating: rating,
      nailedItStreak: streak,
      intervalDays: interval,
      dueAt: dueAt,
      templateAnswers: current.templateAnswers,
    );
  }

  List<InterviewQuestion> orderQueue(
    Iterable<InterviewQuestion> cards,
    Map<String, CardProgress> progress,
    DateTime now,
  ) {
    final indexed = cards.toList().asMap().entries.toList();
    int category(InterviewQuestion card) {
      final record = progress[card.id];
      if (record == null || !record.seen) return 1;
      if (record.dueAt == null || !record.dueAt!.isAfter(now)) return 0;
      return 2;
    }

    indexed.sort((left, right) {
      final leftCard = left.value;
      final rightCard = right.value;
      final categoryComparison = category(
        leftCard,
      ).compareTo(category(rightCard));
      if (categoryComparison != 0) return categoryComparison;
      if (category(leftCard) != 1) {
        final dateComparison = progress[leftCard.id]!.dueAt!.compareTo(
          progress[rightCard.id]!.dueAt!,
        );
        if (dateComparison != 0) return dateComparison;
      }
      return left.key.compareTo(right.key);
    });
    return [for (final entry in indexed) entry.value];
  }
}
