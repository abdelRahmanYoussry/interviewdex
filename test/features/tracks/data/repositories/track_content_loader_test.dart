import 'dart:typed_data';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/data/data_sources/track_asset_source.dart';
import 'package:interviewdex/features/tracks/data/repositories/track_content_loader.dart';
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
      expect(warnings, isEmpty);
    });

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
