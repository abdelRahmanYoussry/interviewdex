import '../entities/track.dart';

abstract interface class TrackRepository {
  Future<List<InterviewTrack>> loadTracks();
}
