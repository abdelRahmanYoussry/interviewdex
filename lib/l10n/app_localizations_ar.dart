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
  String get settingsDescription => 'اختر اللغة والمظهر المناسبين لك.';

  @override
  String get savedAutomatically => 'يتم حفظ اختياراتك على هذا الجهاز.';
}
