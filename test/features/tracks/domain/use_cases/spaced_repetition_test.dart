import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/interview_question.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/spaced_repetition.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

void main() {
  const spacedRepetition = SpacedRepetition();
  final now = DateTime.utc(2026, 11, 11, 12);

  test('Missed returns in ten minutes and breaks the mastery streak', () {
    final result = spacedRepetition.applyRating(
      _progress(streak: 1, interval: 3),
      CardRating.missed,
      now,
    );

    expect(result.seen, isTrue);
    expect(result.lastRating, CardRating.missed);
    expect(result.nailedItStreak, 0);
    expect(result.intervalDays, 0);
    expect(result.dueAt, now.add(const Duration(minutes: 10)));
    expect(result.status, CardProgressStatus.inProgress);
  });

  test('Partly is due in one day and breaks the mastery streak', () {
    final result = spacedRepetition.applyRating(
      _progress(streak: 1, interval: 3),
      CardRating.partly,
      now,
    );

    expect(result.nailedItStreak, 0);
    expect(result.intervalDays, 1);
    expect(result.dueAt, now.add(const Duration(days: 1)));
  });

  test('Nailed it intervals grow 3, 7, 15, then 30 days', () {
    var progress = const CardProgress.notSeen();
    for (final interval in [3, 7, 15, 30, 30]) {
      progress = spacedRepetition.applyRating(
        progress,
        CardRating.nailedIt,
        now,
      );
      expect(progress.intervalDays, interval);
      expect(progress.dueAt, now.add(Duration(days: interval)));
    }
    expect(progress.status, CardProgressStatus.mastered);
  });

  test('mastery requires consecutive Nailed it ratings', () {
    final once = spacedRepetition.applyRating(
      const CardProgress.notSeen(),
      CardRating.nailedIt,
      now,
    );
    expect(once.status, CardProgressStatus.inProgress);
    final reset = spacedRepetition.applyRating(once, CardRating.partly, now);
    final onceAgain = spacedRepetition.applyRating(
      reset,
      CardRating.nailedIt,
      now,
    );
    expect(onceAgain.status, CardProgressStatus.inProgress);
    expect(
      spacedRepetition.applyRating(onceAgain, CardRating.nailedIt, now).status,
      CardProgressStatus.mastered,
    );
  });

  test('queue orders due, not-seen, then future due dates', () {
    final cards = [
      _card('future'),
      _card('unseen'),
      _card('due'),
      _card('later'),
    ];
    final progress = {
      'due': _record(now.subtract(const Duration(minutes: 1))),
      'future': _record(now.add(const Duration(days: 3))),
      'later': _record(now.add(const Duration(days: 1))),
    };

    expect(
      spacedRepetition.orderQueue(cards, progress, now).map((card) => card.id),
      ['due', 'unseen', 'later', 'future'],
    );
  });

  test(
    'unseen records have notSeen status; seen records remain in progress',
    () {
      expect(const CardProgress.notSeen().status, CardProgressStatus.notSeen);
      expect(_record(now).status, CardProgressStatus.inProgress);
    },
  );

  test('rating deadlines are always stored in UTC', () {
    final localNow = DateTime(2026, 11, 11, 12);
    final result = spacedRepetition.applyRating(
      const CardProgress.notSeen(),
      CardRating.partly,
      localNow,
    );

    expect(result.dueAt!.isUtc, isTrue);
  });
}

CardProgress _progress({required int streak, required int interval}) =>
    CardProgress(
      seen: true,
      lastRating: CardRating.nailedIt,
      nailedItStreak: streak,
      intervalDays: interval,
      dueAt: DateTime.utc(2026, 11, 14),
    );

CardProgress _record(DateTime dueAt) => CardProgress(
  seen: true,
  lastRating: CardRating.nailedIt,
  nailedItStreak: 1,
  intervalDays: 3,
  dueAt: dueAt,
);

InterviewQuestion _card(String id) {
  final text = LocalizedText({'en': id, 'ar': id});
  return InterviewQuestion(
    id: id,
    stage: InterviewStage.technical,
    difficulty: QuestionDifficulty.junior,
    source: 'Reason: test',
    question: text,
    keyPoints: [text, text, text],
    answer: text,
    followUp: text,
    commonMistake: text,
  );
}
