import '../../domain/entities/track.dart';
import '../../domain/entities/interview_question.dart';
import '../../domain/entities/quiz_item.dart';
import '../../domain/value_objects/localized_text.dart';
import 'interview_question_model.dart';
import 'quiz_item_model.dart';
import 'json_readers.dart';

class TopicModel {
  static InterviewTopic fromJson(
    JsonObject json,
    String path, {
    required String expectedId,
    required LocalizedText name,
    required void Function(String message) logWarning,
    required Set<String> trackItemIds,
    required Set<String> sourceHosts,
  }) {
    requireKeys(json, {'id', 'interviewCards'}, path);
    requireOnlyKeys(json, {'id', 'interviewCards', 'quiz', 'bugHunts'}, path);
    final id = identifier(json, 'id', path);
    if (id != expectedId) {
      throw FormatException('$path.id must match "$expectedId".');
    }
    final cardsJson = jsonList(json['interviewCards'], '$path.interviewCards');
    final cards = <InterviewQuestion>[];
    for (var index = 0; index < cardsJson.length; index++) {
      final cardPath = '$path.interviewCards[$index]';
      try {
        final question = InterviewQuestionModel.fromJson(
          jsonObject(cardsJson[index], cardPath),
          cardPath,
          sourceHosts: sourceHosts,
        );
        if (trackItemIds.contains(question.id)) {
          throw FormatException(
            '$cardPath.id duplicates "${question.id}" in this track.',
          );
        }
        trackItemIds.add(question.id);
        cards.add(question);
      } on FormatException catch (error) {
        logWarning('Skipping invalid item at $cardPath: ${error.message}');
      }
    }
    final quizItems = <QuizItem>[];
    final quizJson =
        json.containsKey('quiz') ? jsonList(json['quiz'], '$path.quiz') : const [];
    for (var index = 0; index < quizJson.length; index++) {
      final itemPath = '$path.quiz[$index]';
      try {
        final item = QuizItemModel.fromJson(
          jsonObject(quizJson[index], itemPath),
          itemPath,
          sourceHosts: sourceHosts,
        );
        if (trackItemIds.contains(item.id)) {
          throw FormatException(
            '$itemPath.id duplicates "${item.id}" in this track.',
          );
        }
        trackItemIds.add(item.id);
        quizItems.add(item);
      } on FormatException catch (error) {
        logWarning('Skipping invalid item at $itemPath: ${error.message}');
      }
    }
    return InterviewTopic(
      id: id,
      name: name,
      interviewCards: List.unmodifiable(cards),
      quizItems: List.unmodifiable(quizItems),
    );
  }
}
