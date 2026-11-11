import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/card_progress.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../../domain/repositories/practice_progress_repository.dart';

class SharedPreferencesPracticeProgressRepository
    implements PracticeProgressRepository {
  SharedPreferencesPracticeProgressRepository(
    this._preferences, {
    void Function(String message)? logWarning,
  }) : _logWarning = logWarning ?? debugPrint;

  static const _version = 1;
  final SharedPreferences _preferences;
  final void Function(String message) _logWarning;
  Future<void> _queue = Future<void>.value();

  String _key(String trackId) => 'practice.v$_version.$trackId';
  String _backupKey(String trackId) => '${_key(trackId)}.backup';

  @override
  Future<PracticeProgress> load(String trackId) =>
      _enqueue(() => _loadUnsafe(trackId));

  @override
  Future<void> saveCard(String trackId, String cardId, CardProgress progress) =>
      _enqueue(() async {
        final current = await _loadUnsafe(trackId);
        final existing = current.cards[cardId];
        final mergedProgress =
            existing == null
                ? progress
                : CardProgress(
                  seen: progress.seen,
                  lastRating: progress.lastRating,
                  nailedItStreak: progress.nailedItStreak,
                  intervalDays: progress.intervalDays,
                  dueAt: progress.dueAt,
                  templateAnswers: {
                    ...existing.templateAnswers,
                    ...progress.templateAnswers,
                  },
                );
        await _writeUnsafe(
          trackId,
          cards: {...current.cards, cardId: mergedProgress},
          session: current.session,
        );
      });

  @override
  Future<void> saveSession(String trackId, SavedPracticeSession session) =>
      _enqueue(() async {
        final current = await _loadUnsafe(trackId);
        await _writeUnsafe(trackId, cards: current.cards, session: session);
      });

  @override
  Future<void> clearSession(String trackId) => _enqueue(() async {
    final current = await _loadUnsafe(trackId);
    await _writeUnsafe(trackId, cards: current.cards, session: null);
  });

  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) => _enqueue(() async {
    final current = await _loadUnsafe(trackId);
    final existing = current.cards[cardId] ?? const CardProgress.notSeen();
    await _writeUnsafe(
      trackId,
      cards: {
        ...current.cards,
        cardId: CardProgress(
          seen: existing.seen,
          lastRating: existing.lastRating,
          nailedItStreak: existing.nailedItStreak,
          intervalDays: existing.intervalDays,
          dueAt: existing.dueAt,
          templateAnswers: Map.unmodifiable(answers),
        ),
      },
      session: current.session,
    );
  });

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  Future<PracticeProgress> _loadUnsafe(String trackId) async {
    Object? raw;
    try {
      raw = _preferences.get(_key(trackId));
    } on Object catch (error) {
      _logWarning('Unable to read practice progress for "$trackId": $error');
      return const PracticeProgress(cards: {});
    }
    if (raw == null) return const PracticeProgress(cards: {});
    if (raw is! String) {
      return _backupAndReset(trackId, raw, 'stored value is not a string');
    }

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      return _backupAndReset(trackId, raw, 'invalid JSON: $error');
    }
    final root = _stringKeyedMap(decoded);
    if (root == null || root['version'] != _version) {
      return _backupAndReset(trackId, raw, 'invalid or unsupported version');
    }
    final rawCards = _stringKeyedMap(root['cards']);
    if (rawCards == null) {
      return _backupAndReset(trackId, raw, 'invalid card collection');
    }

    final cards = <String, CardProgress>{};
    for (final entry in rawCards.entries) {
      final progress = _decodeCardProgress(entry.value);
      if (progress == null) {
        _logWarning(
          'Skipping invalid practice record "${entry.key}" for "$trackId".',
        );
        continue;
      }
      cards[entry.key] = progress;
    }

    final rawSession = root['session'];
    final session = rawSession == null ? null : _decodeSession(rawSession);
    if (rawSession != null && session == null) {
      _logWarning('Discarding invalid saved session for "$trackId".');
    }
    return PracticeProgress(cards: cards, session: session);
  }

  Future<PracticeProgress> _backupAndReset(
    String trackId,
    Object? raw,
    String reason,
  ) async {
    _logWarning(
      'Resetting unreadable practice progress for "$trackId": $reason.',
    );
    try {
      final backup = raw is String ? raw : jsonEncode(raw);
      await _preferences.setString(_backupKey(trackId), backup);
    } on Object catch (error) {
      _logWarning('Unable to back up practice progress for "$trackId": $error');
    }
    return const PracticeProgress(cards: {});
  }

  Future<void> _writeUnsafe(
    String trackId, {
    required Map<String, CardProgress> cards,
    required SavedPracticeSession? session,
  }) async {
    await _preferences.setString(
      _key(trackId),
      jsonEncode({
        'version': _version,
        'cards': {
          for (final entry in cards.entries)
            entry.key: _encodeCardProgress(entry.value),
        },
        'session': session == null ? null : _encodeSession(session),
      }),
    );
  }

  Map<String, Object?> _encodeCardProgress(CardProgress progress) => {
    'seen': progress.seen,
    'lastRating': progress.lastRating?.name,
    'nailedItStreak': progress.nailedItStreak,
    'intervalDays': progress.intervalDays,
    'dueAt': progress.dueAt?.toUtc().toIso8601String(),
    'templateAnswers': progress.templateAnswers,
  };

  CardProgress? _decodeCardProgress(Object? raw) {
    final value = _stringKeyedMap(raw);
    if (value == null) return null;
    final seen = value['seen'];
    final rawRating = value['lastRating'];
    final nailedItStreak = value['nailedItStreak'];
    final intervalDays = value['intervalDays'];
    final rawDueAt = value['dueAt'];
    final rawAnswers = value['templateAnswers'];
    if (seen is! bool) return null;
    if (nailedItStreak is! int || nailedItStreak < 0) return null;
    if (intervalDays is! int || intervalDays < 0) return null;
    if (rawRating != null && rawRating is! String) return null;
    if (rawDueAt != null && rawDueAt is! String) return null;

    CardRating? rating;
    if (rawRating != null) {
      for (final candidate in CardRating.values) {
        if (candidate.name == rawRating) rating = candidate;
      }
      if (rating == null) return null;
    }

    DateTime? dueAt;
    if (rawDueAt case final String dueAtValue) {
      dueAt = DateTime.tryParse(dueAtValue);
      if (dueAt == null) return null;
      dueAt = dueAt.toUtc();
    }

    final answers = <String, String>{};
    if (rawAnswers != null) {
      final answerMap = _stringKeyedMap(rawAnswers);
      if (answerMap == null) return null;
      for (final entry in answerMap.entries) {
        final answer = entry.value;
        if (answer is! String) return null;
        answers[entry.key] = answer;
      }
    }

    return CardProgress(
      seen: seen,
      lastRating: rating,
      nailedItStreak: nailedItStreak,
      intervalDays: intervalDays,
      dueAt: dueAt,
      templateAnswers: answers,
    );
  }

  Map<String, Object?> _encodeSession(SavedPracticeSession session) => {
    'mode': session.mode.name,
    'cardIds': session.cardIds,
    'index': session.index,
    'revealed': session.revealed,
    'topicId': session.topicId,
    'retriedCardIds': session.retriedCardIds.toList(),
  };

  SavedPracticeSession? _decodeSession(Object? raw) {
    final value = _stringKeyedMap(raw);
    if (value == null) return null;
    final rawMode = value['mode'];
    final rawCardIds = value['cardIds'];
    final index = value['index'];
    final revealed = value['revealed'];
    final topicId = value['topicId'];
    final rawRetried = value['retriedCardIds'];
    List<Object?>? retriedValues;
    if (rawMode is! String) return null;
    if (rawCardIds is! List<Object?>) return null;
    if (index is! int) return null;
    if (revealed is! bool) return null;
    if (topicId != null && topicId is! String) return null;
    if (rawRetried != null) {
      if (rawRetried is! List<Object?>) return null;
      retriedValues = rawRetried;
    }

    PracticeMode? mode;
    for (final candidate in PracticeMode.values) {
      if (candidate.name == rawMode) mode = candidate;
    }
    if (mode == null) return null;
    final cardIdValues = rawCardIds;
    final cardIds = cardIdValues.whereType<String>().toList();
    if (cardIds.length != cardIdValues.length ||
        cardIds.isEmpty ||
        index < 0 ||
        index >= cardIds.length) {
      return null;
    }

    final retriedCardIds =
        retriedValues == null
            ? <String>[]
            : retriedValues.whereType<String>().toList();
    if (retriedValues != null &&
        retriedCardIds.length != retriedValues.length) {
      return null;
    }
    return SavedPracticeSession(
      mode: mode,
      cardIds: cardIds,
      index: index,
      revealed: revealed,
      topicId: topicId is String ? topicId : null,
      retriedCardIds: retriedCardIds.toSet(),
    );
  }

  Map<String, Object?>? _stringKeyedMap(Object? value) {
    if (value is! Map) return null;
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) return null;
      result[key] = entry.value;
    }
    return result;
  }
}
