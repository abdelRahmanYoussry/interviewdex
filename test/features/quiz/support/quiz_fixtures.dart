import 'package:interviewdex/features/tracks/domain/entities/quiz_item.dart';
import 'package:interviewdex/features/tracks/domain/entities/track.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

InterviewTrack quizTrack({
  int topicCount = 3,
  int itemsPerTopic = 5,
  bool englishOnly = false,
  bool includeTrueFalse = false,
}) => InterviewTrack(
  id: 'flutter',
  name: _text('Flutter', 'فلاتر'),
  description: _text('Flutter learning track.', 'مسار تعلم فلاتر.'),
  icon: 'assets/tracks/flutter/track_icon.png',
  topics: [
    for (var topicIndex = 0; topicIndex < topicCount; topicIndex++)
      InterviewTopic(
        id: 'topic_$topicIndex',
        name: _contentText(
          'Topic $topicIndex',
          'الموضوع $topicIndex',
          englishOnly,
        ),
        interviewCards: const [],
        quizItems: [
          for (var itemIndex = 0; itemIndex < itemsPerTopic; itemIndex++)
            quizItem(
              id: 'quiz_${topicIndex}_$itemIndex',
              topicIndex: topicIndex,
              itemIndex: itemIndex,
              englishOnly: englishOnly,
              trueFalse:
                  includeTrueFalse &&
                  topicIndex == 0 &&
                  itemIndex == itemsPerTopic - 1,
            ),
        ],
      ),
  ],
);

QuizItem quizItem({
  required String id,
  int topicIndex = 0,
  int itemIndex = 0,
  bool trueFalse = false,
  bool englishOnly = false,
}) {
  final question = _contentText(
    'Question $topicIndex-$itemIndex?',
    'السؤال $topicIndex-$itemIndex؟',
    englishOnly,
  );
  final why = _contentText(
    'This is why the answer is correct.',
    'هذا سبب صحة الإجابة.',
    englishOnly,
  );
  final tip = _contentText(
    'This is one useful extra tip.',
    'هذه معلومة إضافية مفيدة.',
    englishOnly,
  );
  if (trueFalse) {
    return TrueFalseQuizItem(
      id: id,
      difficulty: QuizDifficulty.junior,
      source: 'https://dart.dev/language/variables',
      question: question,
      why: why,
      tip: tip,
      answer: true,
    );
  }
  return MultipleChoiceQuizItem(
    id: id,
    difficulty: QuizDifficulty.junior,
    source: 'https://dart.dev/language/variables',
    question: question,
    why: why,
    tip: tip,
    options: [
      for (var optionIndex = 0; optionIndex < 4; optionIndex++)
        _contentText(
          'Choice $optionIndex for $topicIndex-$itemIndex',
          'الخيار $optionIndex للسؤال $topicIndex-$itemIndex',
          englishOnly,
        ),
    ],
    correctIndex: 0,
  );
}

LocalizedText _text(String english, String arabic) =>
    LocalizedText({'en': english, 'ar': arabic});

LocalizedText _contentText(String english, String arabic, bool englishOnly) =>
    LocalizedText(
      englishOnly ? {'en': english} : {'en': english, 'ar': arabic},
    );
