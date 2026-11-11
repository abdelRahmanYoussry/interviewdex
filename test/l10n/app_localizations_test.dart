import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/l10n/app_localizations.dart';
import 'package:interviewdex/l10n/app_localizations_ar.dart';
import 'package:interviewdex/l10n/app_localizations_en.dart';

void main() {
  for (final strings in <AppLocalizations>[
    AppLocalizationsEn(),
    AppLocalizationsAr(),
  ]) {
    test('plural messages interpolate each count in ${strings.localeName}', () {
      for (final count in [0, 1, 2, 3, 11, 100]) {
        final messages = <String, String>{
          'quizScore': strings.quizScore(987, count),
          'quizWrongCount': strings.quizWrongCount(count),
          'mastered': strings.masteryProgress(count, 0),
          'total': strings.masteryProgress(0, count),
          'topicCardCount': strings.topicCardCount(count),
          'nailedItStreak': strings
              .nailedItStreak(count)
              .replaceFirst(RegExp(r'( of | من )2$'), ''),
          'mockReviewCount': strings.mockReviewCount(count),
        };
        for (final entry in messages.entries) {
          expect(entry.value, isNot(contains('#')), reason: entry.key);
          if (count != 0 ||
              (entry.key == 'nailedItStreak' && strings.localeName == 'en')) {
            expect(entry.value, contains('$count'), reason: entry.key);
          }
        }
        final progress =
            strings.localeName == 'en'
                ? 'Question 987 of $count'
                : 'السؤال 987 من $count';
        expect(strings.quizQuestionProgress(987, count), progress);
        expect(strings.questionProgress(987, count), progress);
      }
    });
  }
}
