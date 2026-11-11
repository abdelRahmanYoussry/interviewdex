import 'package:equatable/equatable.dart';

enum CardRating { nailedIt, partly, missed }

enum CardProgressStatus { notSeen, mastered, inProgress }

class CardProgress extends Equatable {
  const CardProgress({
    required this.seen,
    required this.lastRating,
    required this.nailedItStreak,
    required this.intervalDays,
    required this.dueAt,
    this.templateAnswers = const {},
  });

  const CardProgress.notSeen()
    : seen = false,
      lastRating = null,
      nailedItStreak = 0,
      intervalDays = 0,
      dueAt = null,
      templateAnswers = const {};

  final bool seen;
  final CardRating? lastRating;
  final int nailedItStreak;
  final int intervalDays;
  final DateTime? dueAt;
  final Map<String, String> templateAnswers;

  CardProgressStatus get status {
    if (!seen) return CardProgressStatus.notSeen;
    if (nailedItStreak >= 2 && lastRating == CardRating.nailedIt) {
      return CardProgressStatus.mastered;
    }
    return CardProgressStatus.inProgress;
  }

  @override
  List<Object?> get props => [
    seen,
    lastRating,
    nailedItStreak,
    intervalDays,
    dueAt,
    templateAnswers,
  ];
}
