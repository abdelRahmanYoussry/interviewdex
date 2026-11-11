import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/track.dart';
import '../data_sources/track_asset_source.dart';
import '../models/json_readers.dart';
import '../models/topic_model.dart';
import '../models/track_model.dart';

class TrackContentLoader {
  TrackContentLoader({
    required TrackAssetSource assetSource,
    void Function(String message)? logWarning,
  }) : _assetSource = assetSource,
       _logWarning = logWarning ?? ((message) => debugPrint(message));

  final TrackAssetSource _assetSource;
  final void Function(String message) _logWarning;

  Future<List<InterviewTrack>> loadTracks() async {
    const indexPath = 'assets/tracks/index.json';
    final index = _decodeObject(
      await _assetSource.loadString(indexPath),
      indexPath,
    );
    requireKeys(index, {'tracks'}, indexPath);
    requireOnlyKeys(index, {'tracks'}, indexPath);
    final descriptorsJson = jsonList(index['tracks'], '$indexPath.tracks');
    if (descriptorsJson.isEmpty) {
      throw FormatException('$indexPath.tracks must not be empty.');
    }

    final descriptors = <TrackDescriptor>[];
    final ids = <String>{};
    for (var index = 0; index < descriptorsJson.length; index++) {
      final path = '$indexPath.tracks[$index]';
      final descriptor = TrackModel.descriptorFromJson(
        jsonObject(descriptorsJson[index], path),
        path,
      );
      if (!ids.add(descriptor.id)) {
        throw FormatException('$path.id duplicates "${descriptor.id}".');
      }
      descriptors.add(descriptor);
    }

    final tracks = <InterviewTrack>[];
    for (final descriptor in descriptors) {
      final trackPath = 'assets/tracks/${descriptor.id}/track.json';
      try {
        final metadata = TrackModel.metadataFromJson(
          _decodeObject(await _assetSource.loadString(trackPath), trackPath),
          trackPath,
        );
        if (metadata.id != descriptor.id) {
          throw FormatException('$trackPath.id must match "${descriptor.id}".');
        }
        final iconPath = 'assets/tracks/${descriptor.id}/${metadata.icon}';
        final iconBytes = await _assetSource.loadBytes(iconPath);
        if (iconBytes.length < 24 ||
            !listEquals(iconBytes.sublist(0, 8), const [
              0x89,
              0x50,
              0x4e,
              0x47,
              0x0d,
              0x0a,
              0x1a,
              0x0a,
            ])) {
          throw FormatException('$iconPath is not a valid PNG image.');
        }
        final pngData = ByteData.sublistView(iconBytes);
        final imageWidth = pngData.getUint32(16);
        final imageHeight = pngData.getUint32(20);
        if (utf8.decode(iconBytes.sublist(12, 16), allowMalformed: true) !=
                'IHDR' ||
            imageWidth == 0 ||
            imageHeight == 0) {
          throw FormatException('$iconPath is not a valid PNG image.');
        }
        final topics = <InterviewTopic>[];
        final cardIds = <String>{};
        for (final topicDescriptor in metadata.topics) {
          final topicPath =
              'assets/tracks/${descriptor.id}/${topicDescriptor.file}';
          try {
            topics.add(
              TopicModel.fromJson(
                _decodeObject(
                  await _assetSource.loadString(topicPath),
                  topicPath,
                ),
                topicPath,
                expectedId: topicDescriptor.id,
                name: topicDescriptor.name,
                logWarning: _logWarning,
                trackCardIds: cardIds,
                sourceHosts: metadata.sourceHosts.toSet(),
              ),
            );
          } on FormatException catch (error) {
            _logWarning(
              'Skipping invalid topic at $topicPath: ${error.message}',
            );
          } on FlutterError catch (error) {
            _logWarning('Skipping unavailable topic at $topicPath: $error');
          }
        }
        tracks.add(
          metadata.toEntity(List.unmodifiable(topics), iconPath: iconPath),
        );
      } on FormatException catch (error) {
        _logWarning('Skipping invalid track at $trackPath: ${error.message}');
      } on FlutterError catch (error) {
        _logWarning('Skipping unavailable track at $trackPath: $error');
      }
    }
    return List.unmodifiable(tracks);
  }

  JsonObject _decodeObject(String source, String path) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('$path contains invalid JSON: ${error.message}');
    }
    return jsonObject(decoded, path);
  }
}
