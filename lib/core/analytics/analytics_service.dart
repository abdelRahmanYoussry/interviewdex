abstract interface class AnalyticsService {
  Future<void> appOpen();

  Future<void> trackOpen(String trackId);

  Future<void> interviewCardReveal({
    required String trackId,
    required String topic,
    required String cardId,
  });

  Future<void> interviewSelfRate({
    required String topic,
    required String rating,
  });

  Future<void> mockInterviewComplete();

  Future<void> quickQuizComplete({required int score, required int total});

  Future<void> levelComplete({required String level, required int stars});

  Future<void> ratingSubmit();
}
