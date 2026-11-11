import 'dart:async';

import 'package:interviewdex/core/analytics/analytics_service.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/entities/interview_question.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/entities/track.dart';
import 'package:interviewdex/features/tracks/domain/repositories/practice_progress_repository.dart';
import 'package:interviewdex/features/tracks/domain/repositories/track_repository.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';

InterviewTrack practiceTrack({String id = 'flutter', String name = 'Flutter'}) {
  final plainText = _text('Question', 'سؤال');
  return InterviewTrack(
    id: id,
    name: _text(name, 'فلاتر'),
    description: _text('Build Flutter applications.', 'أنشئ تطبيقات فلاتر.'),
    icon: 'assets/tracks/flutter/track_icon.png',
    topics: [
      InterviewTopic(
        id: 'core',
        name: _text('Core concepts', 'مفاهيم أساسية'),
        interviewCards: [
          practiceQuestion(
            id: 'intro',
            stage: InterviewStage.intro,
            text: plainText,
          ),
          practiceQuestion(
            id: 'behavioral',
            stage: InterviewStage.behavioral,
            text: plainText,
            fillInTemplate: FillInTemplate(
              template: _text(
                'When [situation], I [action] to achieve [result].',
                'عندما [situation]، قمت بـ[action] لتحقيق [result].',
              ),
              fields: [
                TemplateField(
                  id: 'situation',
                  label: _text('Situation', 'الموقف'),
                  placeholder: _text('A release deadline', 'موعد إصدار'),
                ),
                TemplateField(
                  id: 'action',
                  label: _text('Action', 'الإجراء'),
                  placeholder: _text('I coordinated', 'نسقت'),
                ),
                TemplateField(
                  id: 'result',
                  label: _text('Result', 'النتيجة'),
                  placeholder: _text('We shipped on time', 'أصدرنا في الموعد'),
                ),
              ],
            ),
          ),
        ],
      ),
      InterviewTopic(
        id: 'technical',
        name: _text('Technical', 'تقني'),
        interviewCards: [
          practiceQuestion(
            id: 'technical',
            stage: InterviewStage.technical,
            text: plainText,
          ),
          practiceQuestion(
            id: 'technical-two',
            stage: InterviewStage.technical,
            text: plainText,
          ),
        ],
      ),
      InterviewTopic(
        id: 'live',
        name: _text('Live coding', 'برمجة مباشرة'),
        interviewCards: [
          practiceQuestion(
            id: 'live-one',
            stage: InterviewStage.liveCoding,
            text: plainText,
          ),
          practiceQuestion(
            id: 'live-two',
            stage: InterviewStage.liveCoding,
            text: plainText,
          ),
        ],
      ),
    ],
  );
}

InterviewQuestion practiceQuestion({
  required String id,
  required InterviewStage stage,
  required LocalizedText text,
  FillInTemplate? fillInTemplate,
}) {
  final explanation = _text('Explain your approach.', 'اشرح منهجك.');
  return InterviewQuestion(
    id: id,
    stage: stage,
    difficulty: QuestionDifficulty.junior,
    source: 'Reason: test fixture',
    question: _text('Question $id', 'سؤال $id'),
    keyPoints: [explanation, explanation, explanation],
    answer: _text(
      'A complete sample answer for $id.',
      'إجابة نموذجية مكتملة عن $id.',
    ),
    followUp: explanation,
    commonMistake: explanation,
    fillInTemplate: fillInTemplate,
    liveCoding:
        stage == InterviewStage.liveCoding
            ? LiveCodingDetails(
              language: 'dart',
              solution: 'void main() {}',
              steps: [explanation],
              timeComplexity: _text('O(1)', 'O(1)'),
              spaceComplexity: _text('O(1)', 'O(1)'),
            )
            : null,
  );
}

LocalizedText _text(String english, String arabic) =>
    LocalizedText({'en': english, 'ar': arabic});

class MemoryTrackRepository implements TrackRepository {
  const MemoryTrackRepository(this.tracks);

  final List<InterviewTrack> tracks;

  @override
  Future<List<InterviewTrack>> loadTracks() async => tracks;
}

class MemoryPracticeProgressRepository implements PracticeProgressRepository {
  final Map<String, Map<String, CardProgress>> records = {};
  final Map<String, SavedPracticeSession> sessions = {};

  @override
  Future<PracticeProgress> load(String trackId) async => PracticeProgress(
    cards: Map.unmodifiable(records[trackId] ?? const {}),
    session: sessions[trackId],
  );

  @override
  Future<void> saveCard(
    String trackId,
    String cardId,
    CardProgress progress,
  ) async {
    records.putIfAbsent(trackId, () => {})[cardId] = progress;
  }

  @override
  Future<void> saveSession(String trackId, SavedPracticeSession session) async {
    sessions[trackId] = session;
  }

  @override
  Future<void> clearSession(String trackId) async {
    sessions.remove(trackId);
  }

  @override
  Future<void> saveTemplateAnswers(
    String trackId,
    String cardId,
    Map<String, String> answers,
  ) async {
    final old =
        records.putIfAbsent(trackId, () => {})[cardId] ??
        const CardProgress.notSeen();
    records[trackId]![cardId] = CardProgress(
      seen: old.seen,
      lastRating: old.lastRating,
      nailedItStreak: old.nailedItStreak,
      intervalDays: old.intervalDays,
      dueAt: old.dueAt,
      templateAnswers: Map.unmodifiable(answers),
    );
  }
}

class TestAnalytics implements AnalyticsService {
  Completer<void>? revealCompleter;
  Completer<void>? trackOpenCompleter;
  int mockCompletions = 0;
  final ratings = <String>[];

  @override
  Future<void> appOpen() async {}

  @override
  Future<void> trackOpen(String trackId) =>
      trackOpenCompleter?.future ?? Future<void>.value();

  @override
  Future<void> interviewCardReveal({
    required String trackId,
    required String topic,
    required String cardId,
  }) => revealCompleter?.future ?? Future<void>.value();

  @override
  Future<void> interviewSelfRate({
    required String topic,
    required String rating,
  }) async {
    ratings.add(rating);
  }

  @override
  Future<void> mockInterviewComplete() async {
    mockCompletions += 1;
  }

  @override
  Future<void> levelComplete({
    required String level,
    required int stars,
  }) async {}

  @override
  Future<void> ratingSubmit() async {}
}
