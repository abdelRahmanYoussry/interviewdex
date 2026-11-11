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
  String get tagline => 'أسئلة مقابلات حقيقية لمطوري Flutter. مبني باستخدام Flutter.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get githubRepo => 'مستودع GitHub';

  @override
  String get githubOpenFailure => 'تعذر فتح مستودع GitHub.';

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
  String get startInterview => 'تدرب على المقابلة';

  @override
  String get quickQuiz => 'اختبار سريع';

  @override
  String get quizSubtitle => 'أجب عن أسئلة قصيرة وتعلّم بعد كل إجابة.';

  @override
  String get quizPickerTitle => 'اختر اختبارًا';

  @override
  String get quizAllTopics => 'كل الموضوعات';

  @override
  String get quizResume => 'استكمل الاختبار';

  @override
  String get quizLoadFailure => 'تعذر تحميل الاختبار. حاول مرة أخرى.';

  @override
  String get quizCorrect => 'إجابة صحيحة';

  @override
  String get quizIncorrect => 'ليست صحيحة';

  @override
  String get quizCorrectAnswer => 'الإجابة الصحيحة';

  @override
  String get quizYourAnswer => 'إجابتك';

  @override
  String get quizWhy => 'السبب';

  @override
  String get quizTip => 'معلومة إضافية';

  @override
  String get quizNext => 'التالي';

  @override
  String get quizTrue => 'صحيح';

  @override
  String get quizFalse => 'خطأ';

  @override
  String get quizResults => 'نتيجة الاختبار';

  @override
  String get quizRetryWrong => 'أعد الأسئلة الخاطئة';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String quizScore(int score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total سؤال',
      many: '$total سؤالًا',
      few: '$total أسئلة',
      two: 'سؤالين ($total)',
      one: 'سؤال واحد ($total)',
      zero: 'لا توجد أسئلة',
    );
    return '$score إجابة صحيحة من $_temp0';
  }

  @override
  String quizWrongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة خاطئة',
      many: '$count إجابة خاطئة',
      few: '$count إجابات خاطئة',
      two: 'إجابتان خاطئتان ($count)',
      one: 'إجابة خاطئة واحدة ($count)',
      zero: 'لا توجد إجابات خاطئة',
    );
    return '$_temp0';
  }

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
      other: 'أتقنت $mastered سؤال',
      many: 'أتقنت $mastered سؤالًا',
      few: 'أتقنت $mastered أسئلة',
      two: 'أتقنت سؤالين ($mastered)',
      one: 'أتقنت سؤالًا واحدًا ($mastered)',
      zero: 'لم تتقن أي سؤال',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total سؤال',
      many: '$total سؤالًا',
      few: '$total أسئلة',
      two: 'سؤالان ($total)',
      one: 'سؤال واحد ($total)',
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
      other: '$count سؤال',
      many: '$count سؤالًا',
      few: '$count أسئلة',
      two: 'سؤالان ($count)',
      one: 'سؤال واحد ($count)',
      zero: 'لا توجد أسئلة',
    );
    return '$_temp0';
  }

  @override
  String get practiceTopic => 'تدرب على الموضوع';

  @override
  String questionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String nailedItStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة متقنة',
      many: '$count إجابة متقنة',
      few: '$count إجابات متقنة',
      two: 'إجابتان متقنتان ($count)',
      one: 'إجابة متقنة واحدة ($count)',
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

  @override
  String get mockSummaryTitle => 'نتائج المقابلة التجريبية';

  @override
  String get overallScore => 'النتيجة الإجمالية';

  @override
  String get topicBreakdown => 'درجات الموضوعات';

  @override
  String get mockSummaryEmpty => 'لا توجد تقييمات للمقابلة التجريبية.';

  @override
  String get practiceThisTopic => 'تدرب على هذا الموضوع';

  @override
  String mockReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سؤال للمراجعة',
      many: '$count سؤالًا للمراجعة',
      few: '$count أسئلة للمراجعة',
      two: 'سؤالان للمراجعة ($count)',
      one: 'سؤال واحد للمراجعة ($count)',
      zero: 'لا توجد أسئلة للمراجعة',
    );
    return '$_temp0';
  }
}
