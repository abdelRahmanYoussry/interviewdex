import 'analytics_service.dart';

class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> appOpen() async {}

  @override
  Future<void> trackOpen(String trackId) async {}

  @override
  Future<void> interviewCardReveal({
    required String trackId,
    required String topic,
    required String cardId,
  }) async {}

  @override
  Future<void> interviewSelfRate({
    required String topic,
    required String rating,
  }) async {}

  @override
  Future<void> mockInterviewComplete() async {}

  @override
  Future<void> levelComplete({
    required String level,
    required int stars,
  }) async {}

  @override
  Future<void> ratingSubmit() async {}
}
