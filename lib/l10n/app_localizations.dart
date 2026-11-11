import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'InterviewDex'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Real interview questions for Flutter developers. Built with Flutter.'**
  String get tagline;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Prepare for your next interview'**
  String get homeWelcome;

  /// No description provided for @startInterview.
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get startInterview;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your language and appearance.'**
  String get settingsDescription;

  /// No description provided for @savedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Your choices are saved on this device.'**
  String get savedAutomatically;

  /// No description provided for @trackPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a track'**
  String get trackPickerTitle;

  /// No description provided for @chooseTrack.
  ///
  /// In en, this message translates to:
  /// **'Choose the interview track you want to practice.'**
  String get chooseTrack;

  /// No description provided for @noTracksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No interview tracks are available yet.'**
  String get noTracksAvailable;

  /// No description provided for @trackLoadFailure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load interview tracks.'**
  String get trackLoadFailure;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @masteryProgress.
  ///
  /// In en, this message translates to:
  /// **'{mastered, plural, =0{No cards mastered} one{# card mastered} other{# cards mastered}} of {total, plural, =0{no cards} one{# card} other{# cards}}'**
  String masteryProgress(int mastered, int total);

  /// No description provided for @startMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Start mock interview'**
  String get startMockInterview;

  /// No description provided for @mockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock interview'**
  String get mockInterview;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @topicCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No questions} one{# question} other{# questions}}'**
  String topicCardCount(int count);

  /// No description provided for @practiceTopic.
  ///
  /// In en, this message translates to:
  /// **'Practice topic'**
  String get practiceTopic;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total, plural, =0{no questions} one{# question} other{# questions}}'**
  String questionProgress(int current, int total);

  /// No description provided for @nailedItStreak.
  ///
  /// In en, this message translates to:
  /// **'Nailed it streak: {count, plural, one{# consecutive rating} other{# consecutive ratings}} of 2'**
  String nailedItStreak(int count);

  /// No description provided for @answerFramework.
  ///
  /// In en, this message translates to:
  /// **'Answer framework'**
  String get answerFramework;

  /// No description provided for @resumePractice.
  ///
  /// In en, this message translates to:
  /// **'Resume practice'**
  String get resumePractice;

  /// No description provided for @resumeMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Resume mock interview'**
  String get resumeMockInterview;

  /// No description provided for @partly.
  ///
  /// In en, this message translates to:
  /// **'Partly'**
  String get partly;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @practiceLoadFailure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this practice session.'**
  String get practiceLoadFailure;

  /// No description provided for @startAnswerTimer.
  ///
  /// In en, this message translates to:
  /// **'Start 90-second timer'**
  String get startAnswerTimer;

  /// No description provided for @revealAnswer.
  ///
  /// In en, this message translates to:
  /// **'Reveal answer'**
  String get revealAnswer;

  /// No description provided for @sampleAnswer.
  ///
  /// In en, this message translates to:
  /// **'Sample answer'**
  String get sampleAnswer;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key points'**
  String get keyPoints;

  /// No description provided for @solution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @timeComplexity.
  ///
  /// In en, this message translates to:
  /// **'Time complexity'**
  String get timeComplexity;

  /// No description provided for @spaceComplexity.
  ///
  /// In en, this message translates to:
  /// **'Space complexity'**
  String get spaceComplexity;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @commonMistake.
  ///
  /// In en, this message translates to:
  /// **'Common mistake'**
  String get commonMistake;

  /// No description provided for @mastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get mastered;

  /// No description provided for @nailedIt.
  ///
  /// In en, this message translates to:
  /// **'Nailed it'**
  String get nailedIt;

  /// No description provided for @mockInterviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Mock interview complete. Great work!'**
  String get mockInterviewComplete;

  /// No description provided for @practiceComplete.
  ///
  /// In en, this message translates to:
  /// **'Practice complete. Keep it up!'**
  String get practiceComplete;

  /// No description provided for @backToTrack.
  ///
  /// In en, this message translates to:
  /// **'Back to track'**
  String get backToTrack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
