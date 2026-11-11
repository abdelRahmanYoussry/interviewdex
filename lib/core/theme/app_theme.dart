import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.good,
    required this.goodSoft,
    required this.bad,
    required this.badSoft,
    required this.gold,
    required this.goldSoft,
    required this.heart,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color good;
  final Color goodSoft;
  final Color bad;
  final Color badSoft;
  final Color gold;
  final Color goldSoft;
  final Color heart;

  static const lightColors = AppColors(
    background: Color(0xFFEEF2F9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF5F7FC),
    ink: Color(0xFF131C33),
    muted: Color(0xFF5B6687),
    line: Color(0xFFD9E0EF),
    accent: Color(0xFF2B5CF0),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFE3EAFE),
    good: Color(0xFF128A5C),
    goodSoft: Color(0xFFDEF5EA),
    bad: Color(0xFFD2394B),
    badSoft: Color(0xFFFDE6E8),
    gold: Color(0xFFC98A00),
    goldSoft: Color(0xFFFFF1CC),
    heart: Color(0xFFE9405A),
  );

  static const darkColors = AppColors(
    background: Color(0xFF0D1322),
    surface: Color(0xFF161F36),
    surface2: Color(0xFF1C2742),
    ink: Color(0xFFE9EDF8),
    muted: Color(0xFF9BA7C6),
    line: Color(0xFF2A3657),
    accent: Color(0xFF6F93FF),
    onAccent: Color(0xFF0D1322),
    accentSoft: Color(0xFF22305A),
    good: Color(0xFF3CCB8F),
    goodSoft: Color(0xFF143A2C),
    bad: Color(0xFFFF6B7D),
    badSoft: Color(0xFF43202A),
    gold: Color(0xFFF2C14E),
    goldSoft: Color(0xFF3A2F12),
    heart: Color(0xFFFF6B81),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? good,
    Color? goodSoft,
    Color? bad,
    Color? badSoft,
    Color? gold,
    Color? goldSoft,
    Color? heart,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      good: good ?? this.good,
      goodSoft: goodSoft ?? this.goodSoft,
      bad: bad ?? this.bad,
      badSoft: badSoft ?? this.badSoft,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      heart: heart ?? this.heart,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      good: Color.lerp(good, other.good, t)!,
      goodSoft: Color.lerp(goodSoft, other.goodSoft, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      badSoft: Color.lerp(badSoft, other.badSoft, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      heart: Color.lerp(heart, other.heart, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() {
    return _theme(AppColors.lightColors, Brightness.light);
  }

  static ThemeData dark() {
    return _theme(AppColors.darkColors, Brightness.dark);
  }

  static ThemeData _theme(AppColors colors, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
    ).copyWith(
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      surface: colors.surface,
      onSurface: colors.ink,
      error: colors.bad,
      outline: colors.line,
    );
    final baseTextTheme =
        brightness == Brightness.light
            ? ThemeData.light().textTheme
            : ThemeData.dark().textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['IBMPlexSansArabic'],
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(fontFamily: 'Sora'),
        displayMedium: textTheme.displayMedium?.copyWith(fontFamily: 'Sora'),
        displaySmall: textTheme.displaySmall?.copyWith(fontFamily: 'Sora'),
        headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: 'Sora'),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontFamily: 'Sora'),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: 'Sora'),
      ),
      extensions: [colors],
    );
  }
}
