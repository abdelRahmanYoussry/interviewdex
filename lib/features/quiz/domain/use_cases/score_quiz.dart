import '../../../tracks/domain/entities/quiz_item.dart';
import '../entities/quiz_result.dart';

class ScoreQuiz {
  const ScoreQuiz();

  QuizResult call(List<QuizItem> items, Map<String, int> answers) {
    var score = 0;
    final wrongAnswers = <QuizWrongAnswer>[];
    for (final item in items) {
      final chosenAnswer = answers[item.id];
      if (chosenAnswer == null) continue;
      final correct = switch (item) {
        MultipleChoiceQuizItem(:final correctIndex) =>
          chosenAnswer == correctIndex,
        TrueFalseQuizItem(:final answer) => chosenAnswer == (answer ? 1 : 0),
      };
      if (correct) {
        score++;
      } else {
        wrongAnswers.add(
          QuizWrongAnswer(item: item, chosenAnswer: chosenAnswer),
        );
      }
    }
    return QuizResult(
      score: score,
      total: items.length,
      wrongAnswers: List.unmodifiable(wrongAnswers),
    );
  }
}
