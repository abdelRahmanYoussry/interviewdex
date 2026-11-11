import 'dart:typed_data';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/data/data_sources/track_asset_source.dart';
import 'package:interviewdex/features/tracks/data/repositories/track_content_loader.dart';
import 'package:interviewdex/features/tracks/domain/entities/quiz_item.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackContentLoader', () {
    test('loads real track assets without warnings', () async {
      final warnings = <String>[];
      final tracks =
          await TrackContentLoader(
            assetSource: const FlutterTrackAssetSource(),
            logWarning: warnings.add,
          ).loadTracks();

      expect(tracks, hasLength(1));
      expect(tracks.single.id, 'flutter');
      expect(tracks.single.topics, isNotEmpty);
      expect(tracks.single.icon, 'assets/tracks/flutter/track_icon.png');
      expect(
        tracks.single.topics
            .where((topic) => topic.id != 'behavioral')
            .map((topic) => topic.quizItems.length),
        everyElement(5),
      );
      expect(
        tracks.single.topics
            .singleWhere((topic) => topic.id == 'behavioral')
            .quizItems,
        isEmpty,
      );
      final allQuizItems =
          tracks.single.topics.expand((topic) => topic.quizItems).toList();
      expect(allQuizItems, hasLength(40));
      final even =
          allQuizItems.singleWhere((item) => item.id == 'quiz_live_even_modulo')
              as MultipleChoiceQuizItem;
      expect(even.code, isNull);
      expect(even.options.map((option) => option.resolve('en')), [
        'value % 2 == 0',
        'value % 2 == 1',
        'value ~/ 2 == 0',
        'value / 2 == 0',
      ]);
      expect(even.correctIndex, 0);
      expect(
        even.why.resolve('en'),
        'An even integer leaves a remainder of 0 when divided by 2.',
      );
      expect(
        even.tip.resolve('en'),
        'Dart integers also have isEven and isOdd getters, for example value.isEven.',
      );
      final ownership =
          allQuizItems.singleWhere(
                (item) => item.id == 'quiz_stateful_state_ownership',
              )
              as MultipleChoiceQuizItem;
      expect(
        ownership.options.map((option) => option.resolve('en')),
        contains('In a static field on the StatefulWidget class'),
      );
      expect(
        allQuizItems
            .singleWhere((item) => item.id == 'quiz_live_immutable_input')
            .difficulty,
        QuizDifficulty.junior,
      );
      expect(warnings, isEmpty);
    });

    test('parses both multiple-choice and true-false quiz items', () async {
      final warnings = <String>[];
      final withCode = _validQuizItem('with_code')
        ..['code'] = 'final count = 3;';
      final invalidCode = _validQuizItem('invalid_code')
        ..['code'] = {'en': 'final count = 3;'};
      final tracks =
          await _loader(
            topicFiles: {
              'basics.json': _topicWithQuiz('basics', [
                withCode,
                _validQuizItem('true_false', type: 'trueFalse'),
                invalidCode,
              ]),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics.single.quizItems, hasLength(2));
      expect(
        (tracks.single.topics.single.quizItems.first as MultipleChoiceQuizItem)
            .code,
        'final count = 3;',
      );
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('must be a non-empty code string'));
    });

    test(
      'skips and logs invalid quiz items without dropping valid ones',
      () async {
        final duplicateOptions = _validQuizItem('duplicate_options')
          ..['options'] = [
            {'en': 'Same option'},
            {'en': 'Same option'},
            {'en': 'Third option'},
            {'en': 'Fourth option'},
          ];
        final invalidBoolean = _validQuizItem(
          'invalid_boolean',
          type: 'trueFalse',
        )..['answer'] = 'true';
        final warnings = <String>[];
        final tracks =
            await _loader(
              topicFiles: {
                'basics.json': _topicWithQuiz('basics', [
                  _validQuizItem('valid_item'),
                  duplicateOptions,
                  invalidBoolean,
                ]),
              },
              warnings: warnings,
            ).loadTracks();

        expect(tracks.single.topics.single.quizItems.map((item) => item.id), [
          'valid_item',
        ]);
        expect(warnings, hasLength(2));
        expect(warnings.first, contains('must be distinct'));
        expect(warnings.last, contains('must be a boolean'));
      },
    );

    test(
      'quiz ids are unique with interview card ids across the track',
      () async {
        final warnings = <String>[];
        final tracks =
            await _loader(
              topicFiles: {
                'basics.json': _topicWithQuiz(
                  'basics',
                  [_validQuizItem('shared_id')],
                  cards: [_validCard('shared_id')],
                ),
              },
              warnings: warnings,
            ).loadTracks();

        expect(tracks.single.topics.single.interviewCards, hasLength(1));
        expect(tracks.single.topics.single.quizItems, isEmpty);
        expect(warnings, hasLength(1));
        expect(warnings.single, contains('duplicates "shared_id"'));
      },
    );

    test('skips and logs an invalid track', () async {
      final warnings = <String>[];
      final tracks =
          await _loader(
            topicFiles: const {},
            warnings: warnings,
            trackJson: jsonEncode({'id': 'flutter'}),
          ).loadTracks();

      expect(tracks, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('Skipping invalid track'));
    });

    test('skips and logs an invalid topic', () async {
      final warnings = <String>[];
      final tracks =
          await _loader(
            topicFiles: {
              'basics.json': jsonEncode({'id': 'basics'}),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('Skipping invalid topic'));
    });

    test('skips and logs a topic with broken JSON', () async {
      final warnings = <String>[];
      final tracks =
          await _loader(
            topicFiles: {'basics.json': '{"id":'},
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('invalid JSON'));
    });

    test('rejects duplicate card ids across different topics', () async {
      final warnings = <String>[];
      final tracks =
          await _loader(
            topicFiles: {
              'basics.json': _topic('basics', [_validCard('shared_card')]),
              'dart.json': _topic('dart', [_validCard('shared_card')]),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics.first.interviewCards, hasLength(1));
      expect(tracks.single.topics.last.interviewCards, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('duplicates "shared_card"'));
    });

    test('skips cards with mismatched live-coding details', () async {
      final warnings = <String>[];
      final missingDetails = _validCard('missing_solution')
        ..['stage'] = 'liveCoding';
      final unexpectedDetails = _validCard('unexpected_solution')
        ..['liveCoding'] = {
          'language': 'dart',
          'solution': 'String answer() => "ok";',
          'steps': [
            {'en': 'Return a value.'},
          ],
          'complexity': {
            'time': {'en': 'O(1)'},
            'space': {'en': 'O(1)'},
          },
        };
      final tracks =
          await _loader(
            topicFiles: {
              'live.json': _topic('live', [missingDetails, unexpectedDetails]),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics.single.interviewCards, isEmpty);
      expect(warnings, hasLength(2));
      expect(warnings.first, contains('liveCoding is required'));
      expect(warnings.last, contains('required only'));
    });

    test('rejects a URL on a host not listed by the track', () async {
      final warnings = <String>[];
      final card = _validCard('untrusted_source')
        ..['source'] = 'https://other.example/docs';
      final tracks =
          await _loader(
            topicFiles: {
              'basics.json': _topic('basics', [card]),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics.single.interviewCards, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('configured source host'));
    });

    test(
      'accepts a Reason source at any stage without card-specific rules',
      () async {
        final warnings = <String>[];
        final card = _validCard('new_track_card')..['stage'] = 'technical';
        final tracks =
            await _loader(
              topicFiles: {
                'basics.json': _topic('basics', [card]),
              },
              warnings: warnings,
            ).loadTracks();

        expect(tracks.single.topics.single.interviewCards, hasLength(1));
        expect(warnings, isEmpty);
      },
    );

    test('loads another track with its own configured source hosts', () async {
      final warnings = <String>[];
      final card = _validCard('frontend_card')
        ..['source'] = 'https://docs.frontend.example/interviews';
      final frontendTrack = {
        'id': 'frontend',
        'name': {'en': 'Frontend'},
        'description': {'en': 'Frontend interview practice.'},
        'icon': 'track_icon.png',
        'sourceHosts': ['docs.frontend.example'],
        'topics': [
          {
            'id': 'frontend_basics',
            'name': {'en': 'Frontend basics'},
            'file': 'frontend_basics.json',
          },
        ],
      };
      final assets = <String, String>{
        'assets/tracks/index.json': jsonEncode({
          'tracks': [
            {'id': 'frontend'},
          ],
        }),
        'assets/tracks/frontend/track.json': jsonEncode(frontendTrack),
        'assets/tracks/frontend/frontend_basics.json': _topic(
          'frontend_basics',
          [card],
        ),
      };
      final tracks =
          await TrackContentLoader(
            assetSource: MapTrackAssetSource(assets),
            logWarning: warnings.add,
          ).loadTracks();

      expect(tracks, hasLength(1));
      expect(tracks.single.id, 'frontend');
      expect(
        tracks.single.topics.single.interviewCards.single.id,
        'frontend_card',
      );
      expect(warnings, isEmpty);
    });

    test(
      'rejects a template placeholder in any templated card answer',
      () async {
        final card =
            _validCard('templated_intro')
              ..['stage'] = 'intro'
              ..['answer'] = {'en': 'I worked on {project}.'}
              ..['fillInTemplate'] = {
                'template': {'en': 'I worked on {project}.'},
                'fields': [
                  {
                    'id': 'project',
                    'label': {'en': 'Project'},
                    'placeholder': {'en': 'an app'},
                  },
                ],
              };
        final warnings = <String>[];
        final tracks =
            await _loader(
              topicFiles: {
                'intro.json': _topic('intro', [card]),
              },
              warnings: warnings,
            ).loadTracks();

        expect(tracks.single.topics.single.interviewCards, isEmpty);
        expect(warnings, hasLength(1));
        expect(warnings.single, contains('complete example'));
      },
    );

    test('accepts future Arabic localized values', () async {
      final card = _validCard('localized_card')
        ..['question'] = {'en': 'Question?', 'ar': 'سؤال؟'};
      final tracks =
          await _loader(
            topicFiles: {
              'basics.json': _topic('basics', [card]),
            },
            warnings: [],
          ).loadTracks();

      expect(
        tracks.single.topics.single.interviewCards.single.question.resolve(
          'ar',
        ),
        'سؤال؟',
      );
    });

    test('rejects template placeholders without matching field ids', () async {
      final card = _validCard('bad_template')
        ..['fillInTemplate'] = {
          'template': {'en': 'I worked on {project}.'},
          'fields': [
            {
              'id': 'company',
              'label': {'en': 'Company'},
              'placeholder': {'en': 'an example'},
            },
          ],
        };
      final warnings = <String>[];
      final tracks =
          await _loader(
            topicFiles: {
              'behavioral.json': _topic('behavioral', [card]),
            },
            warnings: warnings,
          ).loadTracks();

      expect(tracks.single.topics.single.interviewCards, isEmpty);
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('unknown placeholder'));
    });

    test('LocalizedText falls back to English', () {
      const englishOnly = {'en': 'Hello'};
      final text = LocalizedText(englishOnly);

      expect(text.resolve('ar'), 'Hello');
      expect(text.resolve('en-US'), 'Hello');
      expect(
        text.resolveWith('ar'),
        const ResolvedLocalizedText('Hello', 'en'),
      );
    });
  });
}

TrackContentLoader _loader({
  required Map<String, String> topicFiles,
  required List<String> warnings,
  String? trackJson,
}) {
  final topics =
      topicFiles.keys.map((file) {
        final id = file.substring(0, file.length - '.json'.length);
        return {
          'id': id,
          'name': {'en': id},
          'file': file,
        };
      }).toList();
  final assets = <String, String>{
    'assets/tracks/index.json': jsonEncode({
      'tracks': [
        {'id': 'flutter'},
      ],
    }),
    'assets/tracks/flutter/track.json':
        trackJson ??
        jsonEncode({
          'id': 'flutter',
          'name': {'en': 'Flutter'},
          'description': {'en': 'A test track.'},
          'icon': 'track_icon.png',
          'sourceHosts': ['dart.dev', 'docs.flutter.dev', 'pub.dev'],
          'topics': topics,
        }),
  };
  for (final entry in topicFiles.entries) {
    assets['assets/tracks/flutter/${entry.key}'] = entry.value;
  }
  return TrackContentLoader(
    assetSource: MapTrackAssetSource(assets),
    logWarning: warnings.add,
  );
}

String _topic(String id, List<Map<String, dynamic>> cards) =>
    jsonEncode({'id': id, 'interviewCards': cards});

String _topicWithQuiz(
  String id,
  List<Map<String, dynamic>> quiz, {
  List<Map<String, dynamic>> cards = const [],
}) => jsonEncode({'id': id, 'interviewCards': cards, 'quiz': quiz});

Map<String, dynamic> _validQuizItem(
  String id, {
  String type = 'multipleChoice',
}) => {
  'id': id,
  'type': type,
  'difficulty': 'junior',
  'source': 'https://dart.dev/language/variables',
  'question': {'en': 'What is the correct choice?'},
  if (type == 'multipleChoice') ...{
    'options': [
      {'en': 'First answer'},
      {'en': 'Second answer'},
      {'en': 'Third answer'},
      {'en': 'Fourth answer'},
    ],
    'correctIndex': 0,
  },
  if (type == 'trueFalse') 'answer': true,
  'why': {'en': 'The first answer matches the rule.'},
  'tip': {'en': 'Remember this rule for the next example.'},
};

class MapTrackAssetSource implements TrackAssetSource {
  MapTrackAssetSource(this.assets);

  final Map<String, String> assets;

  @override
  Future<String> loadString(String path) async {
    final value = assets[path];
    if (value == null) throw StateError('Missing test asset: $path');
    return value;
  }

  @override
  Future<Uint8List> loadBytes(String path) async {
    if (path.endsWith('.png')) {
      return Uint8List.fromList(const [
        0x89,
        0x50,
        0x4e,
        0x47,
        0x0d,
        0x0a,
        0x1a,
        0x0a,
        0x00,
        0x00,
        0x00,
        0x0d,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
      ]);
    }
    throw StateError('Missing test binary asset: $path');
  }
}

Map<String, dynamic> _validCard(String id) => {
  'id': id,
  'stage': 'behavioral',
  'difficulty': 'junior',
  'source': 'Reason: This card practices one relevant interview skill.',
  'question': {'en': 'What is a widget?'},
  'keyPoints': [
    {'en': 'It describes UI.'},
    {'en': 'It is immutable.'},
    {'en': 'It is part of a tree.'},
  ],
  'answer': {'en': 'A widget describes one part of the user interface.'},
  'followUp': {'en': 'What is an Element?'},
  'commonMistake': {'en': 'Do not call it a rendered pixel.'},
};
