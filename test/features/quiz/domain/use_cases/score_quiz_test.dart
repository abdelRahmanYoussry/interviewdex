import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/entities/quiz_item.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/score_quiz.dart';

import '../../support/quiz_fixtures.dart';

void main() {
  const scoreQuiz = ScoreQuiz();

  test('scores correct and incorrect answers and lists wrong items', () {
    final correct = quizItem(id: 'correct');
    final incorrect = quizItem(id: 'incorrect', itemIndex: 1);
    final skipped = quizItem(id: 'skipped', itemIndex: 2);

    final result = scoreQuiz(
      [correct, incorrect, skipped],
      {'correct': 0, 'incorrect': 2},
    );

    expect(result.score, 1);
    expect(result.total, 3);
    expect(result.wrongAnswers.map((answer) => answer.item.id), ['incorrect']);
  });

  test('scores true and false answers using canonical indexes', () {
    final trueItem = quizItem(id: 'true', trueFalse: true);
    final falseItem =
        quizItem(id: 'false', trueFalse: true, itemIndex: 1)
            as TrueFalseQuizItem;
    final result = scoreQuiz([trueItem, falseItem], {'true': 1, 'false': 0});

    expect(result.score, 1);
    expect(result.wrongAnswers.single.item.id, 'false');
  });

  test('supports empty and all-correct results', () {
    expect(scoreQuiz([], {}).score, 0);
    final items = [quizItem(id: 'one'), quizItem(id: 'two')];
    final result = scoreQuiz(items, {'one': 0, 'two': 0});

    expect(result.score, 2);
    expect(result.wrongAnswers, isEmpty);
  });
}
