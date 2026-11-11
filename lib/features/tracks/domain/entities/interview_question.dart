import 'package:equatable/equatable.dart';

import '../value_objects/localized_text.dart';

enum QuestionDifficulty { junior, mid, senior }

enum InterviewStage { intro, behavioral, technical, liveCoding }

class InterviewQuestion extends Equatable {
  const InterviewQuestion({
    required this.id,
    required this.stage,
    required this.difficulty,
    required this.source,
    required this.question,
    required this.keyPoints,
    required this.answer,
    required this.followUp,
    required this.commonMistake,
    this.fillInTemplate,
    this.liveCoding,
  });

  final String id;
  final InterviewStage stage;
  final QuestionDifficulty difficulty;
  final String source;
  final LocalizedText question;
  final List<LocalizedText> keyPoints;
  final LocalizedText answer;
  final LocalizedText followUp;
  final LocalizedText commonMistake;
  final FillInTemplate? fillInTemplate;
  final LiveCodingDetails? liveCoding;

  @override
  List<Object?> get props => [
    id,
    stage,
    difficulty,
    source,
    question,
    keyPoints,
    answer,
    followUp,
    commonMistake,
    fillInTemplate,
    liveCoding,
  ];
}

class FillInTemplate extends Equatable {
  const FillInTemplate({required this.template, required this.fields});

  final LocalizedText template;
  final List<TemplateField> fields;

  @override
  List<Object> get props => [template, fields];
}

class TemplateField extends Equatable {
  const TemplateField({
    required this.id,
    required this.label,
    required this.placeholder,
  });

  final String id;
  final LocalizedText label;
  final LocalizedText placeholder;

  @override
  List<Object> get props => [id, label, placeholder];
}

class LiveCodingDetails extends Equatable {
  const LiveCodingDetails({
    required this.language,
    required this.solution,
    required this.steps,
    required this.timeComplexity,
    required this.spaceComplexity,
  });

  final String language;
  final String solution;
  final List<LocalizedText> steps;
  final LocalizedText timeComplexity;
  final LocalizedText spaceComplexity;

  @override
  List<Object> get props => [
    language,
    solution,
    steps,
    timeComplexity,
    spaceComplexity,
  ];
}
