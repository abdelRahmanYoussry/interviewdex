import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/repositories/practice_progress_repository.dart';

class TemplateAnswerSaver {
  TemplateAnswerSaver(
    this._repository, {
    Duration debounce = const Duration(milliseconds: 400),
    void Function(String message)? logWarning,
  }) : _debounce = debounce,
       _logWarning = logWarning ?? debugPrint;

  final PracticeProgressRepository _repository;
  final Duration _debounce;
  final void Function(String message) _logWarning;
  final Map<(String, String), _PendingTemplateWrite> _pending = {};

  Future<void> save(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) {
    final key = (trackId, cardId);
    final completer = Completer<void>();
    final pending = _pending[key];
    if (pending == null) {
      _pending[key] = _PendingTemplateWrite(
        answers: Map.unmodifiable(answers),
        completers: [completer],
      );
    } else {
      pending.timer?.cancel();
      pending.answers = Map.unmodifiable(answers);
      pending.completers.add(completer);
    }
    final current = _pending[key]!;
    current.timer = Timer(_debounce, () => unawaited(_flush(key, current)));
    return completer.future;
  }

  Future<void> flush() async {
    final pending = _pending.entries.toList();
    for (final entry in pending) {
      entry.value.timer?.cancel();
      await _flush(entry.key, entry.value);
    }
  }

  Future<void> _flush(
    (String, String) key,
    _PendingTemplateWrite pending,
  ) async {
    if (!identical(_pending[key], pending)) return;
    pending.timer?.cancel();
    _pending.remove(key);
    try {
      await _repository.saveTemplateAnswers(key.$1, key.$2, pending.answers);
    } on Object catch (error) {
      _logWarning('Unable to save answer template: $error');
    } finally {
      for (final completer in pending.completers) {
        if (!completer.isCompleted) completer.complete();
      }
    }
  }
}

class _PendingTemplateWrite {
  _PendingTemplateWrite({required this.answers, required this.completers});

  Map<String, String> answers;
  final List<Completer<void>> completers;
  Timer? timer;
}
