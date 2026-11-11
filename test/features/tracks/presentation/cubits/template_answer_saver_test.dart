import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/template_answer_saver.dart';

import '../../support/practice_fixtures.dart';

void main() {
  test('debounces repeated edits and flushes the latest answer', () async {
    final repository = CountingTemplateRepository();
    final saver = TemplateAnswerSaver(
      repository,
      debounce: const Duration(milliseconds: 10),
    );

    final first = saver.save('flutter', 'card-a', const {
      'situation': 'Release',
    });
    final second = saver.save('flutter', 'card-a', const {
      'situation': 'Production release',
    });
    await Future.wait([first, second]);

    expect(repository.templateSaveCount, 1);
    expect(
      repository.records['flutter']!['card-a']!.templateAnswers['situation'],
      'Production release',
    );
    await saver.flush();
  });

  test('flush persists pending values immediately', () async {
    final repository = CountingTemplateRepository();
    final warnings = <String>[];
    final saver = TemplateAnswerSaver(repository, logWarning: warnings.add);
    final save = saver.save('flutter', 'card-a', const {'field': 'value'});

    await saver.flush();
    await save;

    expect(repository.templateSaveCount, 1);
    expect(warnings, isEmpty);
  });

  test('save failures are logged and do not propagate', () async {
    final warnings = <String>[];
    final saver = TemplateAnswerSaver(
      FailingTemplateRepository(),
      debounce: Duration.zero,
      logWarning: warnings.add,
    );

    await saver.save('flutter', 'card-a', const {'field': 'value'});

    expect(warnings, hasLength(1));
  });
}

class CountingTemplateRepository extends MemoryPracticeProgressRepository {
  int templateSaveCount = 0;

  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) async {
    templateSaveCount += 1;
    await super.saveTemplateAnswers(trackId, cardId, answers);
  }
}

class FailingTemplateRepository extends MemoryPracticeProgressRepository {
  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) async {
    throw StateError('Storage unavailable');
  }
}
