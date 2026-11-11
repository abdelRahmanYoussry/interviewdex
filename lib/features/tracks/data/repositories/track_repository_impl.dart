import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import 'track_content_loader.dart';

class TrackRepositoryImpl implements TrackRepository {
  const TrackRepositoryImpl(this._loader);

  final TrackContentLoader _loader;

  @override
  Future<List<InterviewTrack>> loadTracks() => _loader.loadTracks();
}
