import 'package:equatable/equatable.dart';

class LocalizedText extends Equatable {
  LocalizedText(Map<String, String> values)
    : values = Map.unmodifiable(values) {
    if (this.values.isEmpty ||
        !this.values.containsKey('en') ||
        this.values.values.any((value) => value.trim().isEmpty)) {
      throw ArgumentError.value(
        values,
        'values',
        'Must include non-empty English and localized text.',
      );
    }
  }

  final Map<String, String> values;

  ResolvedLocalizedText resolveWith(String languageCode) {
    final normalizedLanguageCode = languageCode.replaceAll('_', '-');
    final exact = values[normalizedLanguageCode];
    if (exact != null) {
      return ResolvedLocalizedText(exact, normalizedLanguageCode);
    }

    final baseLanguageCode = normalizedLanguageCode.split('-').first;
    final base = values[baseLanguageCode];
    if (base != null) return ResolvedLocalizedText(base, baseLanguageCode);
    return ResolvedLocalizedText(values['en']!, 'en');
  }

  String resolve(String languageCode) => resolveWith(languageCode).text;

  @override
  List<Object> get props => [values];
}

class ResolvedLocalizedText extends Equatable {
  const ResolvedLocalizedText(this.text, this.languageCode);

  final String text;
  final String languageCode;

  @override
  List<Object> get props => [text, languageCode];
}
