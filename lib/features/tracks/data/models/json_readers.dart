import '../../domain/value_objects/localized_text.dart';

typedef JsonObject = Map<String, dynamic>;

String requiredString(JsonObject json, String key, String path) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('$path.$key must be a non-empty string.');
}

LocalizedText localizedText(Object? value, String path) {
  if (value is! Map<String, dynamic> || value.isEmpty) {
    throw FormatException('$path must be a non-empty localized text map.');
  }

  final result = <String, String>{};
  for (final entry in value.entries) {
    if (!RegExp(r'^[a-z]{2}(-[A-Z]{2})?$').hasMatch(entry.key) ||
        entry.value is! String ||
        (entry.value as String).trim().isEmpty) {
      throw FormatException(
        '$path.${entry.key} must contain a locale and non-empty string.',
      );
    }
    result[entry.key] = entry.value as String;
  }
  if (!result.containsKey('en')) {
    throw FormatException('$path must include an "en" value.');
  }
  return LocalizedText(result);
}

JsonObject jsonObject(Object? value, String path) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$path must be an object.');
}

List<Object?> jsonList(Object? value, String path) {
  if (value is List<Object?>) return value;
  throw FormatException('$path must be an array.');
}

String identifier(JsonObject json, String key, String path) {
  final value = requiredString(json, key, path);
  if (!RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$').hasMatch(value)) {
    throw FormatException('$path.$key must be a lowercase snake_case id.');
  }
  return value;
}

void requireKeys(JsonObject json, Set<String> keys, String path) {
  final missing = keys.difference(json.keys.toSet());
  if (missing.isNotEmpty) {
    throw FormatException('$path is missing: ${missing.join(', ')}.');
  }
}

void requireOnlyKeys(JsonObject json, Set<String> keys, String path) {
  final unexpected = json.keys.toSet().difference(keys);
  if (unexpected.isNotEmpty) {
    throw FormatException(
      '$path has unsupported fields: ${unexpected.join(', ')}.',
    );
  }
}
