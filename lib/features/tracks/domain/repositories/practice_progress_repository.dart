import '../entities/card_progress.dart';
import '../entities/saved_practice_session.dart';

class PracticeProgress extends Object {
  const PracticeProgress({required this.cards, this.session});

  final Map<String, CardProgress> cards;
  final SavedPracticeSession? session;
}

abstract interface class PracticeProgressRepository {
  Future<PracticeProgress> load(String trackId);

  Future<void> saveCard(String trackId, String cardId, CardProgress progress);

  Future<void> saveSession(String trackId, SavedPracticeSession session);

  Future<void> clearSession(String trackId);

  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  );
}
