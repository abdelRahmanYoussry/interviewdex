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

  String resolve(String languageCode) {
    final normalizedLanguageCode = languageCode.replaceAll('_', '-');
    final exact = values[normalizedLanguageCode];
    if (exact != null) return exact;

    final baseLanguageCode = normalizedLanguageCode.split('-').first;
    return values[baseLanguageCode] ?? values['en']!;
  }

  @override
  List<Object> get props => [values];
}
