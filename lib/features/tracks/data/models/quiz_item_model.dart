import '../../domain/entities/quiz_item.dart';
import '../../domain/value_objects/localized_text.dart';
import 'interview_question_model.dart';
import 'json_readers.dart';

class QuizItemModel {
  static QuizItem fromJson(
    JsonObject json,
    String path, {
    required Set<String> sourceHosts,
  }) {
    final type = requiredString(json, 'type', path);
    final required = {
      'id',
      'type',
      'difficulty',
      'source',
      'question',
      'why',
      'tip',
    };
    final allowed = {
      ...required,
      'code',
      if (type == 'multipleChoice') 'options',
      if (type == 'multipleChoice') 'correctIndex',
      if (type == 'trueFalse') 'answer',
    };
    requireKeys(json, required, path);
    requireOnlyKeys(json, allowed, path);

    final id = identifier(json, 'id', path);
    final difficulty = _difficulty(requiredString(json, 'difficulty', path), path);
    final source = InterviewQuestionModel.validateSource(
      json['source'],
      '$path.source',
      sourceHosts: sourceHosts,
    );
    final question = localizedText(json['question'], '$path.question');
    final why = _shortExplanation(json['why'], '$path.why');
    final tip = _shortExplanation(json['tip'], '$path.tip');
    final code = json.containsKey('code')
        ? _code(json['code'], '$path.code')
        : null;

    if (type == 'multipleChoice') {
      final optionsJson = jsonList(json['options'], '$path.options');
      if (optionsJson.length != 4) {
        throw FormatException('$path.options must contain exactly 4 items.');
      }
      final options = [
        for (var index = 0; index < optionsJson.length; index++)
          localizedText(optionsJson[index], '$path.options[$index]'),
      ];
      final localeCodes = options.expand((option) => option.values.keys).toSet();
      for (final locale in localeCodes) {
        final values = options.map((option) => option.values[locale]).toList();
        if (values.toSet().length != values.length) {
          throw FormatException(
            '$path.options must be distinct for locale "$locale".',
          );
        }
      }
      final correctIndex = json['correctIndex'];
      if (correctIndex is! int || correctIndex < 0 || correctIndex > 3) {
        throw FormatException('$path.correctIndex must be between 0 and 3.');
      }
      return MultipleChoiceQuizItem(
        id: id,
        difficulty: difficulty,
        source: source,
        question: question,
        why: why,
        tip: tip,
        options: List.unmodifiable(options),
        correctIndex: correctIndex,
        code: code,
      );
    }
    if (type == 'trueFalse') {
      final answer = json['answer'];
      if (answer is! bool) {
        throw FormatException('$path.answer must be a boolean.');
      }
      return TrueFalseQuizItem(
        id: id,
        difficulty: difficulty,
        source: source,
        question: question,
        why: why,
        tip: tip,
        answer: answer,
        code: code,
      );
    }
    throw FormatException('$path.type must be multipleChoice or trueFalse.');
  }

  static QuizDifficulty _difficulty(String value, String path) {
    for (final difficulty in QuizDifficulty.values) {
      if (difficulty.name == value) return difficulty;
    }
    throw FormatException('$path.difficulty has unsupported value "$value".');
  }

  static LocalizedText _shortExplanation(Object? value, String path) {
    final text = localizedText(value, path);
    for (final entry in text.values.entries) {
      final sentences = RegExp(r'[.!?](?:\s|$)')
          .allMatches(entry.value.trim())
          .length;
      if (sentences < 1 || sentences > 2) {
        throw FormatException('$path.${entry.key} must contain 1 or 2 sentences.');
      }
    }
    return text;
  }

  static String _code(Object? value, String path) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('$path must be a non-empty code string.');
  }
}
