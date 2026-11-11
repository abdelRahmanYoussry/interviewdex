import 'dart:math';

import '../../../tracks/domain/entities/quiz_item.dart';
import '../../../tracks/domain/entities/track.dart';
import '../entities/built_quiz.dart';

class BuildQuiz {
  const BuildQuiz();

  BuiltQuiz call(
    InterviewTrack track, {
    String? topicId,
    required Random random,
    int itemCount = 10,
  }) {
    final items = [
      for (final topic in track.topics)
        if (topicId == null || topic.id == topicId) ...topic.quizItems,
    ];
    final unique = <String, QuizItem>{};
    for (final item in items) {
      unique.putIfAbsent(item.id, () => item);
    }
    final selection = unique.values.toList()..shuffle(random);
    final selected = selection.take(itemCount).toList();
    final optionOrders = <String, List<int>>{};
    for (final item in selected) {
      if (item is MultipleChoiceQuizItem) {
        optionOrders[item.id] = [0, 1, 2, 3]..shuffle(random);
      } else {
        optionOrders[item.id] = [0, 1]..shuffle(random);
      }
    }
    return BuiltQuiz(
      trackId: track.id,
      topicId: topicId,
      items: List.unmodifiable(selected),
      optionOrders: Map.unmodifiable(optionOrders),
    );
  }
}
