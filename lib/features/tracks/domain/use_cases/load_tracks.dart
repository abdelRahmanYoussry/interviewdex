import '../entities/track.dart';
import '../repositories/track_repository.dart';

class LoadTracks {
  const LoadTracks(this._repository);

  final TrackRepository _repository;

  Future<List<InterviewTrack>> call() => _repository.loadTracks();
}
