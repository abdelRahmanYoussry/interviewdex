import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interviewdex/features/quiz/data/repositories/shared_preferences_quiz_progress_repository.dart';
import 'package:interviewdex/features/quiz/domain/entities/saved_quiz_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('round trips a versioned quiz session', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesQuizProgressRepository(preferences);
    const saved = SavedQuizSession(
      trackId: 'flutter',
      topicId: 'dart_language',
      itemIds: ['quiz_one', 'quiz_two'],
      index: 1,
      answers: {'quiz_one': 2},
      optionOrders: {
        'quiz_one': [3, 1, 0, 2],
        'quiz_two': [0, 2, 1, 3],
      },
    );

    await repository.save('flutter', saved);

    expect(await repository.load('flutter'), saved);
    expect(preferences.getString('quiz.v1.flutter'), contains('"version":1'));
  });

  test('backs up unreadable JSON and starts with empty progress', () async {
    final warnings = <String>[];
    SharedPreferences.setMockInitialValues({'quiz.v1.flutter': '{"broken"'});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesQuizProgressRepository(
      preferences,
      logWarning: warnings.add,
    );

    expect(await repository.load('flutter'), isNull);
    expect(preferences.getString('quiz.v1.flutter'), isNull);
    expect(preferences.getString('quiz.v1.flutter.backup'), '{"broken"');
    expect(warnings, hasLength(2));
  });

  test('backs up values with an unsupported version', () async {
    final raw = jsonEncode({'version': 2, 'trackId': 'flutter'});
    SharedPreferences.setMockInitialValues({'quiz.v1.flutter': raw});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesQuizProgressRepository(
      preferences,
      logWarning: (_) {},
    );

    expect(await repository.load('flutter'), isNull);
    expect(preferences.getString('quiz.v1.flutter.backup'), raw);
  });

  test('backs up malformed nested fields without throwing', () async {
    final raw = jsonEncode({
      'version': 1,
      'trackId': 'flutter',
      'topicId': null,
      'itemIds': ['quiz_one'],
      'index': 0,
      'answers': {'quiz_one': 'not-an-index'},
      'optionOrders': {
        'quiz_one': [0, 1, 2, 3],
      },
    });
    SharedPreferences.setMockInitialValues({'quiz.v1.flutter': raw});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesQuizProgressRepository(
      preferences,
      logWarning: (_) {},
    );

    expect(await repository.load('flutter'), isNull);
    expect(preferences.getString('quiz.v1.flutter.backup'), raw);
  });

  test('serializes save and clear operations in call order', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesQuizProgressRepository(preferences);
    const saved = SavedQuizSession(
      trackId: 'flutter',
      itemIds: ['quiz_one'],
      index: 0,
      answers: {},
      optionOrders: {
        'quiz_one': [0, 1, 2, 3],
      },
    );

    await Future.wait([
      repository.save('flutter', saved),
      repository.clear('flutter'),
    ]);

    expect(await repository.load('flutter'), isNull);
  });
}
