import '../../domain/entities/interview_question.dart';
import '../../domain/value_objects/localized_text.dart';
import 'json_readers.dart';

class InterviewQuestionModel {
  static InterviewQuestion fromJson(
    JsonObject json,
    String path, {
    required Set<String> sourceHosts,
  }) {
    requireKeys(json, {
      'id',
      'stage',
      'difficulty',
      'source',
      'question',
      'keyPoints',
      'answer',
      'followUp',
      'commonMistake',
    }, path);
    requireOnlyKeys(json, {
      'id',
      'stage',
      'difficulty',
      'source',
      'question',
      'keyPoints',
      'answer',
      'followUp',
      'commonMistake',
      'fillInTemplate',
      'liveCoding',
    }, path);

    final id = identifier(json, 'id', path);
    final stage = _enumValue(
      InterviewStage.values,
      requiredString(json, 'stage', path),
      path,
      'stage',
    );
    final difficulty = _enumValue(
      QuestionDifficulty.values,
      requiredString(json, 'difficulty', path),
      path,
      'difficulty',
    );
    final keyPointsJson = jsonList(json['keyPoints'], '$path.keyPoints');
    if (keyPointsJson.length != 3) {
      throw FormatException('$path.keyPoints must contain exactly 3 items.');
    }

    final fillInTemplate =
        json.containsKey('fillInTemplate')
            ? _fillInTemplate(json['fillInTemplate'], '$path.fillInTemplate')
            : null;
    final liveCoding =
        json.containsKey('liveCoding')
            ? _liveCoding(json['liveCoding'], '$path.liveCoding')
            : null;
    if ((stage == InterviewStage.liveCoding) != (liveCoding != null)) {
      throw FormatException(
        '$path.liveCoding is required only when stage is "liveCoding".',
      );
    }

    final answer = localizedText(json['answer'], '$path.answer');
    if ((stage == InterviewStage.behavioral || fillInTemplate != null) &&
        answer.values.values.any((text) => RegExp(r'[{}]').hasMatch(text))) {
      throw FormatException(
        '$path.answer must be a complete example without template placeholders.',
      );
    }

    return InterviewQuestion(
      id: id,
      stage: stage,
      difficulty: difficulty,
      source: _source(json['source'], '$path.source', sourceHosts: sourceHosts),
      question: localizedText(json['question'], '$path.question'),
      keyPoints: List.unmodifiable([
        for (var index = 0; index < keyPointsJson.length; index++)
          localizedText(keyPointsJson[index], '$path.keyPoints[$index]'),
      ]),
      answer: answer,
      followUp: localizedText(json['followUp'], '$path.followUp'),
      commonMistake: localizedText(
        json['commonMistake'],
        '$path.commonMistake',
      ),
      fillInTemplate: fillInTemplate,
      liveCoding: liveCoding,
    );
  }

  static String _source(
    Object? value,
    String path, {
    required Set<String> sourceHosts,
  }) {
    if (value is! String || value.trim().isEmpty || value.trim().length > 300) {
      throw FormatException('$path must be a non-empty source string.');
    }
    final source = value.trim();
    if (source.startsWith('Reason: ')) {
      if (source.length <= 'Reason: '.length) {
        throw FormatException('$path must include a short reason.');
      }
      return source;
    }

    final uri = Uri.tryParse(source);
    if (uri == null ||
        uri.scheme != 'https' ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        !sourceHosts.contains(uri.host.toLowerCase())) {
      throw FormatException(
        '$path must be a "Reason: " text or HTTPS URL on a configured source host.',
      );
    }
    return source;
  }

  static T _enumValue<T extends Enum>(
    Iterable<T> values,
    String value,
    String path,
    String key,
  ) {
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    throw FormatException('$path.$key has unsupported value "$value".');
  }

  static FillInTemplate _fillInTemplate(Object? value, String path) {
    final json = jsonObject(value, path);
    requireKeys(json, {'template', 'fields'}, path);
    requireOnlyKeys(json, {'template', 'fields'}, path);
    final fieldsJson = jsonList(json['fields'], '$path.fields');
    if (fieldsJson.isEmpty) {
      throw FormatException('$path.fields must not be empty.');
    }
    final template = localizedText(json['template'], '$path.template');
    final fields = List<TemplateField>.unmodifiable([
      for (var index = 0; index < fieldsJson.length; index++)
        _templateField(fieldsJson[index], '$path.fields[$index]'),
    ]);
    _validateTemplate(template, fields, '$path.template');
    return FillInTemplate(template: template, fields: fields);
  }

  static void _validateTemplate(
    LocalizedText template,
    List<TemplateField> fields,
    String path,
  ) {
    final fieldIds = fields.map((field) => field.id).toSet();
    if (fieldIds.length != fields.length) {
      throw FormatException('$path fields must have unique ids.');
    }
    final placeholderPattern = RegExp(r'\{([^{}]+)\}');
    for (final entry in template.values.entries) {
      final matches = placeholderPattern.allMatches(entry.value);
      final placeholders = matches.map((match) => match[1]!).toSet();
      if (!fieldIds.containsAll(placeholders) ||
          RegExp(
            r'[{}]',
          ).hasMatch(entry.value.replaceAll(placeholderPattern, ''))) {
        throw FormatException(
          '$path.${entry.key} contains an unmatched or unknown placeholder.',
        );
      }
    }
  }

  static TemplateField _templateField(Object? value, String path) {
    final json = jsonObject(value, path);
    requireKeys(json, {'id', 'label', 'placeholder'}, path);
    requireOnlyKeys(json, {'id', 'label', 'placeholder'}, path);
    return TemplateField(
      id: identifier(json, 'id', path),
      label: localizedText(json['label'], '$path.label'),
      placeholder: localizedText(json['placeholder'], '$path.placeholder'),
    );
  }

  static LiveCodingDetails _liveCoding(Object? value, String path) {
    final json = jsonObject(value, path);
    requireKeys(json, {'language', 'solution', 'steps', 'complexity'}, path);
    requireOnlyKeys(json, {
      'language',
      'solution',
      'steps',
      'complexity',
    }, path);
    final complexity = jsonObject(json['complexity'], '$path.complexity');
    requireKeys(complexity, {'time', 'space'}, '$path.complexity');
    requireOnlyKeys(complexity, {'time', 'space'}, '$path.complexity');
    final stepsJson = jsonList(json['steps'], '$path.steps');
    if (stepsJson.isEmpty) {
      throw FormatException('$path.steps must not be empty.');
    }
    return LiveCodingDetails(
      language: requiredString(json, 'language', path),
      solution: _codeString(json['solution'], '$path.solution'),
      steps: List.unmodifiable([
        for (var index = 0; index < stepsJson.length; index++)
          localizedText(stepsJson[index], '$path.steps[$index]'),
      ]),
      timeComplexity: localizedText(
        complexity['time'],
        '$path.complexity.time',
      ),
      spaceComplexity: localizedText(
        complexity['space'],
        '$path.complexity.space',
      ),
    );
  }

  static String _codeString(Object? value, String path) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('$path must be a non-empty code string.');
  }
}
