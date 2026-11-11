import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saved_quiz_session.dart';
import '../../domain/repositories/quiz_progress_repository.dart';

class SharedPreferencesQuizProgressRepository
    implements QuizProgressRepository {
  SharedPreferencesQuizProgressRepository(
    this._preferences, {
    void Function(String message)? logWarning,
  }) : _logWarning = logWarning ?? debugPrint;

  static const _version = 1;
  final SharedPreferences _preferences;
  final void Function(String message) _logWarning;
  Future<void> _queue = Future<void>.value();

  String _key(String trackId) => 'quiz.v$_version.$trackId';

  @override
  Future<SavedQuizSession?> load(String trackId) =>
      _enqueue(() async => _decode(trackId));

  @override
  Future<void> save(String trackId, SavedQuizSession session) =>
      _enqueue(() async {
        await _preferences.setString(
          _key(trackId),
          jsonEncode({
            'version': _version,
            'trackId': session.trackId,
            'topicId': session.topicId,
            'itemIds': session.itemIds,
            'index': session.index,
            'answers': session.answers,
            'optionOrders': session.optionOrders,
          }),
        );
      });

  @override
  Future<void> clear(String trackId) =>
      _enqueue(() async => _preferences.remove(_key(trackId)));

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  Future<SavedQuizSession?> _decode(String trackId) async {
    final key = _key(trackId);
    final raw = _preferences.get(key);
    if (raw == null) return null;
    SavedQuizSession? session;
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        session = _parse(decoded, trackId);
      } on FormatException catch (error) {
        _logWarning('Unreadable quiz progress for "$trackId": $error');
      }
    }
    if (session != null) return session;

    _logWarning(
      'Backing up and resetting invalid quiz progress for "$trackId".',
    );
    try {
      await _preferences.setString(
        '$key.backup',
        raw is String ? raw : jsonEncode(raw),
      );
    } on Exception catch (error) {
      _logWarning('Unable to back up quiz progress for "$trackId": $error');
    }
    try {
      await _preferences.remove(key);
    } on Exception catch (error) {
      _logWarning(
        'Unable to clear invalid quiz progress for "$trackId": $error',
      );
    }
    return null;
  }

  SavedQuizSession? _parse(Object? decoded, String expectedTrackId) {
    final map = _stringMap(decoded);
    if (map == null ||
        map['version'] != _version ||
        map['trackId'] != expectedTrackId ||
        map['itemIds'] is! List<Object?> ||
        map['index'] is! int ||
        map['answers'] is! Map ||
        map['optionOrders'] is! Map) {
      return null;
    }
    final rawTopicId = map['topicId'];
    if (rawTopicId != null && rawTopicId is! String) return null;
    final rawIds = map['itemIds'] as List<Object?>;
    final itemIds = rawIds.whereType<String>().toList();
    final index = map['index'] as int;
    if (itemIds.isEmpty ||
        itemIds.length != rawIds.length ||
        index < 0 ||
        index >= itemIds.length) {
      return null;
    }
    final rawAnswers = _stringMap(map['answers']);
    final rawOrders = _stringMap(map['optionOrders']);
    if (rawAnswers == null || rawOrders == null) return null;
    final answers = <String, int>{};
    for (final entry in rawAnswers.entries) {
      if (!itemIds.contains(entry.key) ||
          entry.value is! int ||
          (entry.value as int) < 0 ||
          (entry.value as int) > 3) {
        return null;
      }
      answers[entry.key] = entry.value as int;
    }
    final optionOrders = <String, List<int>>{};
    for (final entry in rawOrders.entries) {
      if (!itemIds.contains(entry.key) || entry.value is! List<Object?>) {
        return null;
      }
      final values = (entry.value as List<Object?>).whereType<int>().toList();
      if (values.length != (entry.value as List<Object?>).length ||
          values.toSet().length != values.length ||
          values.any((value) => value < 0 || value > 3)) {
        return null;
      }
      optionOrders[entry.key] = List.unmodifiable(values);
    }
    return SavedQuizSession(
      trackId: expectedTrackId,
      topicId: rawTopicId is String ? rawTopicId : null,
      itemIds: List.unmodifiable(itemIds),
      index: index,
      answers: Map.unmodifiable(answers),
      optionOrders: Map.unmodifiable(optionOrders),
    );
  }

  Map<String, Object?>? _stringMap(Object? value) {
    if (value is! Map) return null;
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is! String) return null;
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
