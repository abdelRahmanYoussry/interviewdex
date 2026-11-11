import 'package:equatable/equatable.dart';

import '../value_objects/localized_text.dart';

enum QuizDifficulty { junior, mid, senior }

sealed class QuizItem extends Equatable {
  const QuizItem({
    required this.id,
    required this.difficulty,
    required this.source,
    required this.question,
    required this.why,
    required this.tip,
    this.code,
  });

  final String id;
  final QuizDifficulty difficulty;
  final String source;
  final LocalizedText question;
  final String? code;
  final LocalizedText why;
  final LocalizedText tip;

  @override
  List<Object?> get props => [id, difficulty, source, question, code, why, tip];
}

class MultipleChoiceQuizItem extends QuizItem {
  const MultipleChoiceQuizItem({
    required super.id,
    required super.difficulty,
    required super.source,
    required super.question,
    required super.why,
    required super.tip,
    required this.options,
    required this.correctIndex,
    super.code,
  });

  final List<LocalizedText> options;
  final int correctIndex;

  @override
  List<Object?> get props => [...super.props, options, correctIndex];
}

class TrueFalseQuizItem extends QuizItem {
  const TrueFalseQuizItem({
    required super.id,
    required super.difficulty,
    required super.source,
    required super.question,
    required super.why,
    required super.tip,
    required this.answer,
    super.code,
  });

  final bool answer;

  @override
  List<Object?> get props => [...super.props, answer];
}
