import '../../domain/entities/track.dart';
import '../../domain/value_objects/localized_text.dart';
import 'json_readers.dart';

class TrackDescriptor {
  const TrackDescriptor({required this.id});

  final String id;
}

class TrackModel {
  static TrackDescriptor descriptorFromJson(JsonObject json, String path) {
    requireKeys(json, {'id'}, path);
    requireOnlyKeys(json, {'id'}, path);
    return TrackDescriptor(id: identifier(json, 'id', path));
  }

  static TrackMetadata metadataFromJson(JsonObject json, String path) {
    requireKeys(json, {
      'id',
      'name',
      'description',
      'icon',
      'sourceHosts',
      'topics',
    }, path);
    requireOnlyKeys(json, {
      'id',
      'name',
      'description',
      'icon',
      'sourceHosts',
      'topics',
    }, path);
    final sourceHostsJson = jsonList(json['sourceHosts'], '$path.sourceHosts');
    if (sourceHostsJson.isEmpty) {
      throw FormatException('$path.sourceHosts must not be empty.');
    }
    final sourceHosts = <String>[];
    final uniqueSourceHosts = <String>{};
    for (var index = 0; index < sourceHostsJson.length; index++) {
      final host = sourceHostsJson[index];
      if (host is! String ||
          !RegExp(
            r'^(?=.{1,253}$)[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$',
          ).hasMatch(host)) {
        throw FormatException(
          '$path.sourceHosts[$index] must be a lowercase hostname.',
        );
      }
      if (!uniqueSourceHosts.add(host)) {
        throw FormatException('$path.sourceHosts contains duplicate "$host".');
      }
      sourceHosts.add(host);
    }
    final topicsJson = jsonList(json['topics'], '$path.topics');
    if (topicsJson.isEmpty) {
      throw FormatException('$path.topics must not be empty.');
    }
    final topics = <TopicDescriptor>[];
    final ids = <String>{};
    for (var index = 0; index < topicsJson.length; index++) {
      final topicPath = '$path.topics[$index]';
      final topic = jsonObject(topicsJson[index], topicPath);
      requireKeys(topic, {'id', 'name', 'file'}, topicPath);
      requireOnlyKeys(topic, {'id', 'name', 'file'}, topicPath);
      final id = identifier(topic, 'id', topicPath);
      if (!ids.add(id)) {
        throw FormatException('$topicPath.id duplicates "$id".');
      }
      final file = requiredString(topic, 'file', topicPath);
      if (!RegExp(r'^[a-z0-9_]+\.json$').hasMatch(file)) {
        throw FormatException('$topicPath.file must be a JSON filename.');
      }
      topics.add(
        TopicDescriptor(
          id: id,
          name: localizedText(topic['name'], '$topicPath.name'),
          file: file,
        ),
      );
    }
    return TrackMetadata(
      id: identifier(json, 'id', path),
      name: localizedText(json['name'], '$path.name'),
      description: localizedText(json['description'], '$path.description'),
      icon: _iconFile(requiredString(json, 'icon', path), '$path.icon'),
      sourceHosts: List.unmodifiable(sourceHosts),
      topics: List.unmodifiable(topics),
    );
  }

  static String _iconFile(String value, String path) {
    if (!RegExp(r'^[a-z0-9_-]+\.png$').hasMatch(value)) {
      throw FormatException(
        '$path must be a PNG image filename inside the track folder.',
      );
    }
    return value;
  }
}

class TrackMetadata {
  const TrackMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.sourceHosts,
    required this.topics,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final String icon;
  final List<String> sourceHosts;
  final List<TopicDescriptor> topics;

  InterviewTrack toEntity(
    List<InterviewTopic> topics, {
    required String iconPath,
  }) => InterviewTrack(
    id: id,
    name: name,
    description: description,
    icon: iconPath,
    topics: topics,
  );
}

class TopicDescriptor {
  const TopicDescriptor({
    required this.id,
    required this.name,
    required this.file,
  });

  final String id;
  final LocalizedText name;
  final String file;
}
