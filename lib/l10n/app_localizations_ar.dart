// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'InterviewDex';

  @override
  String get tagline =>
      'أسئلة مقابلات حقيقية لمطوري Flutter. مبني باستخدام Flutter.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'حسب النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get homeWelcome => 'استعد لمقابلتك القادمة';

  @override
  String get startInterview => 'ابدأ الاستعداد';

  @override
  String get settingsDescription => 'اختر اللغة والمظهر المناسبين لك.';

  @override
  String get savedAutomatically => 'يتم حفظ اختياراتك على هذا الجهاز.';

  @override
  String get trackPickerTitle => 'اختر المسار';

  @override
  String get chooseTrack => 'اختر مسار المقابلة الذي تريد التدرب عليه.';

  @override
  String get noTracksAvailable => 'لا توجد مسارات مقابلات متاحة بعد.';

  @override
  String get trackLoadFailure => 'تعذر تحميل مسارات المقابلات.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String masteryProgress(int mastered, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      mastered,
      locale: localeName,
      other: 'أتقنت # سؤال',
      many: 'أتقنت # سؤالًا',
      few: 'أتقنت # أسئلة',
      two: 'أتقنت سؤالين',
      one: 'أتقنت سؤالًا واحدًا',
      zero: 'لم تتقن أي سؤال',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# سؤال',
      many: '# سؤالًا',
      few: '# أسئلة',
      two: 'سؤالان',
      one: 'سؤال واحد',
      zero: 'لا توجد أسئلة',
    );
    return '$_temp0 من أصل $_temp1';
  }

  @override
  String get startMockInterview => 'ابدأ مقابلة تجريبية';

  @override
  String get mockInterview => 'مقابلة تجريبية';

  @override
  String get practiceTitle => 'تدرب';

  @override
  String get topics => 'الموضوعات';

  @override
  String topicCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# سؤال',
      many: '# سؤالًا',
      few: '# أسئلة',
      two: 'سؤالان',
      one: 'سؤال واحد',
      zero: 'لا توجد أسئلة',
    );
    return '$_temp0';
  }

  @override
  String get practiceTopic => 'تدرب على الموضوع';

  @override
  String questionProgress(int current, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# سؤال',
      many: '# سؤالًا',
      few: '# أسئلة',
      two: 'سؤالان',
      one: 'سؤال واحد',
      zero: 'لا توجد أسئلة',
    );
    return 'السؤال $current من $_temp0';
  }

  @override
  String nailedItStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# إجابة متقنة',
      many: '# إجابة متقنة',
      few: '# إجابات متقنة',
      two: 'إجابتان متقنتان',
      one: 'إجابة متقنة واحدة',
      zero: 'لا توجد إجابات متقنة',
    );
    return 'سلسلة الإجابات المتقنة: $_temp0 من 2';
  }

  @override
  String get answerFramework => 'إطار الإجابة';

  @override
  String get resumePractice => 'استكمل التدريب';

  @override
  String get resumeMockInterview => 'استكمل المقابلة التجريبية';

  @override
  String get partly => 'جزئيًا';

  @override
  String get missed => 'لم أجب';

  @override
  String get practiceLoadFailure => 'تعذر فتح جلسة التدريب.';

  @override
  String get startAnswerTimer => 'ابدأ مؤقت 90 ثانية';

  @override
  String get revealAnswer => 'اعرض الإجابة';

  @override
  String get sampleAnswer => 'إجابة نموذجية';

  @override
  String get keyPoints => 'النقاط الرئيسية';

  @override
  String get solution => 'الحل';

  @override
  String get steps => 'الخطوات';

  @override
  String get timeComplexity => 'التعقيد الزمني';

  @override
  String get spaceComplexity => 'التعقيد المكاني';

  @override
  String get followUp => 'سؤال متابعة';

  @override
  String get commonMistake => 'خطأ شائع';

  @override
  String get mastered => 'تم الإتقان';

  @override
  String get nailedIt => 'أجبت بإتقان';

  @override
  String get mockInterviewComplete => 'اكتملت المقابلة التجريبية. أحسنت!';

  @override
  String get practiceComplete => 'اكتمل التدريب. واصل التقدم!';

  @override
  String get backToTrack => 'العودة إلى المسار';
}
