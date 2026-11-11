import '../../domain/entities/track.dart';
import '../../domain/entities/interview_question.dart';
import '../../domain/value_objects/localized_text.dart';
import 'interview_question_model.dart';
import 'json_readers.dart';

class TopicModel {
  static InterviewTopic fromJson(
    JsonObject json,
    String path, {
    required String expectedId,
    required LocalizedText name,
    required void Function(String message) logWarning,
    required Set<String> trackCardIds,
    required Set<String> sourceHosts,
  }) {
    requireKeys(json, {'id', 'interviewCards'}, path);
    requireOnlyKeys(json, {'id', 'interviewCards', 'quiz', 'bugHunts'}, path);
    for (final optionalList in ['quiz', 'bugHunts']) {
      if (json.containsKey(optionalList)) {
        final items = jsonList(json[optionalList], '$path.$optionalList');
        for (var index = 0; index < items.length; index++) {
          jsonObject(items[index], '$path.$optionalList[$index]');
        }
      }
    }
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
        if (trackCardIds.contains(question.id)) {
          throw FormatException(
            '$cardPath.id duplicates "${question.id}" in this track.',
          );
        }
        trackCardIds.add(question.id);
        cards.add(question);
      } on FormatException catch (error) {
        logWarning('Skipping invalid item at $cardPath: ${error.message}');
      }
    }
    return InterviewTopic(
      id: id,
      name: name,
      interviewCards: List.unmodifiable(cards),
    );
  }
}
