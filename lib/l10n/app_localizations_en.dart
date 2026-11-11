// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'InterviewDex';

  @override
  String get tagline =>
      'Real interview questions for Flutter developers. Built with Flutter.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get homeWelcome => 'Prepare for your next interview';

  @override
  String get startInterview => 'Start preparing';

  @override
  String get settingsDescription => 'Choose your language and appearance.';

  @override
  String get savedAutomatically => 'Your choices are saved on this device.';

  @override
  String get trackPickerTitle => 'Choose a track';

  @override
  String get chooseTrack => 'Choose the interview track you want to practice.';

  @override
  String get noTracksAvailable => 'No interview tracks are available yet.';

  @override
  String get trackLoadFailure => 'We couldn\'t load interview tracks.';

  @override
  String get retry => 'Try again';

  @override
  String masteryProgress(int mastered, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      mastered,
      locale: localeName,
      other: '# cards mastered',
      one: '# card mastered',
      zero: 'No cards mastered',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# cards',
      one: '# card',
      zero: 'no cards',
    );
    return '$_temp0 of $_temp1';
  }

  @override
  String get startMockInterview => 'Start mock interview';

  @override
  String get mockInterview => 'Mock interview';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get topics => 'Topics';

  @override
  String topicCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# questions',
      one: '# question',
      zero: 'No questions',
    );
    return '$_temp0';
  }

  @override
  String get practiceTopic => 'Practice topic';

  @override
  String questionProgress(int current, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# questions',
      one: '# question',
      zero: 'no questions',
    );
    return 'Question $current of $_temp0';
  }

  @override
  String nailedItStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# consecutive ratings',
      one: '# consecutive rating',
    );
    return 'Nailed it streak: $_temp0 of 2';
  }

  @override
  String get answerFramework => 'Answer framework';

  @override
  String get resumePractice => 'Resume practice';

  @override
  String get resumeMockInterview => 'Resume mock interview';

  @override
  String get partly => 'Partly';

  @override
  String get missed => 'Missed';

  @override
  String get practiceLoadFailure => 'We couldn\'t open this practice session.';

  @override
  String get startAnswerTimer => 'Start 90-second timer';

  @override
  String get revealAnswer => 'Reveal answer';

  @override
  String get sampleAnswer => 'Sample answer';

  @override
  String get keyPoints => 'Key points';

  @override
  String get solution => 'Solution';

  @override
  String get steps => 'Steps';

  @override
  String get timeComplexity => 'Time complexity';

  @override
  String get spaceComplexity => 'Space complexity';

  @override
  String get followUp => 'Follow-up';

  @override
  String get commonMistake => 'Common mistake';

  @override
  String get mastered => 'Mastered';

  @override
  String get nailedIt => 'Nailed it';

  @override
  String get mockInterviewComplete => 'Mock interview complete. Great work!';

  @override
  String get practiceComplete => 'Practice complete. Keep it up!';

  @override
  String get backToTrack => 'Back to track';
}
