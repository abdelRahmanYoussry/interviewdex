import 'package:equatable/equatable.dart';

import '../../../tracks/domain/entities/quiz_item.dart';

class QuizWrongAnswer extends Equatable {
  const QuizWrongAnswer({required this.item, required this.chosenAnswer});

  final QuizItem item;
  final int chosenAnswer;

  @override
  List<Object> get props => [item, chosenAnswer];
}

class QuizResult extends Equatable {
  const QuizResult({
    required this.score,
    required this.total,
    required this.wrongAnswers,
  });

  final int score;
  final int total;
  final List<QuizWrongAnswer> wrongAnswers;

  @override
  List<Object> get props => [score, total, wrongAnswers];
}
