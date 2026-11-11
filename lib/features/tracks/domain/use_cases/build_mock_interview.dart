import 'dart:math';

import '../entities/card_progress.dart';
import '../entities/interview_question.dart';
import '../entities/practice_card.dart';
import '../entities/track.dart';

class BuildMockInterview {
  const BuildMockInterview();

  List<PracticeCard> call(
    InterviewTrack track,
    Map<String, CardProgress> progress,
    Random random, {
    DateTime? now,
  }) {
    final cards = [
      for (final topic in track.topics)
        for (final question in topic.interviewCards)
          PracticeCard(
            topicId: topic.id,
            topicName: topic.name,
            question: question,
          ),
    ];
    if (cards.isEmpty) return const [];

    final currentTime = (now ?? DateTime.now()).toUtc();
    final selected = <PracticeCard>[];
    final selectedIds = <String>{};

    List<PracticeCard> shuffledPreferred(
      Iterable<PracticeCard> source, {
      bool preferDueOrUnmastered = true,
    }) {
      final result = source.toList()..shuffle(random);
      if (!preferDueOrUnmastered) return result;
      result.sort((left, right) {
        int priority(PracticeCard card) {
          final record = progress[card.question.id];
          if (record == null || !record.seen) return 0;
          final due = record.dueAt?.toUtc();
          if (due != null && !due.isAfter(currentTime)) return 0;
          return record.status == CardProgressStatus.mastered ? 1 : 0;
        }

        return priority(left).compareTo(priority(right));
      });
      return result;
    }

    PracticeCard? take(List<PracticeCard> source) {
      for (final card in source) {
        if (selectedIds.add(card.question.id)) {
          selected.add(card);
          return card;
        }
      }
      return null;
    }

    final technicalQueue = _roundRobinTechnical(
      track,
      progress,
      random,
      currentTime,
    );
    final intros = shuffledPreferred(
      cards.where((card) => card.question.stage == InterviewStage.intro),
    );
    if (intros.isNotEmpty) {
      take(intros);
    } else if (technicalQueue.isNotEmpty) {
      take(technicalQueue);
    }

    final behaviorals = shuffledPreferred(
      cards.where((card) => card.question.stage == InterviewStage.behavioral),
    );
    for (final card in behaviorals.take(2)) {
      take([card]);
    }
    for (
      var missingBehavioral = behaviorals.length;
      missingBehavioral < 2 && technicalQueue.isNotEmpty;
      missingBehavioral++
    ) {
      take(technicalQueue);
    }

    for (var i = 0; i < 6 && technicalQueue.isNotEmpty; i++) {
      take(technicalQueue);
    }

    if (selected.length < 10) {
      final liveCoding = shuffledPreferred(
        cards.where((card) => card.question.stage == InterviewStage.liveCoding),
      );
      take(liveCoding);
    }
    return selected.take(10).toList();
  }

  List<PracticeCard> _roundRobinTechnical(
    InterviewTrack track,
    Map<String, CardProgress> progress,
    Random random,
    DateTime now,
  ) {
    final topics = track.topics.toList()..shuffle(random);
    final queues = <List<PracticeCard>>[
      for (final topic in topics)
        _prioritize(
          [
            for (final question in topic.interviewCards)
              if (question.stage == InterviewStage.technical)
                PracticeCard(
                  topicId: topic.id,
                  topicName: topic.name,
                  question: question,
                ),
          ],
          progress,
          random,
          now,
        ),
    ]..removeWhere((queue) => queue.isEmpty);
    final result = <PracticeCard>[];
    while (queues.isNotEmpty) {
      for (var i = 0; i < queues.length;) {
        result.add(queues[i].removeAt(0));
        if (queues[i].isEmpty) {
          queues.removeAt(i);
        } else {
          i++;
        }
      }
    }
    return result;
  }

  List<PracticeCard> _prioritize(
    List<PracticeCard> cards,
    Map<String, CardProgress> progress,
    Random random,
    DateTime now,
  ) {
    cards.shuffle(random);
    cards.sort((left, right) {
      int priority(PracticeCard card) {
        final record = progress[card.question.id];
        if (record == null || !record.seen) return 0;
        final due = record.dueAt?.toUtc();
        if (due != null && !due.isAfter(now)) return 0;
        return record.status == CardProgressStatus.mastered ? 1 : 0;
      }

      return priority(left).compareTo(priority(right));
    });
    return cards;
  }
}
