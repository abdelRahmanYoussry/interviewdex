import '../entities/saved_quiz_session.dart';

abstract interface class QuizProgressRepository {
  Future<SavedQuizSession?> load(String trackId);

  Future<void> save(String trackId, SavedQuizSession session);

  Future<void> clear(String trackId);
}
