import 'package:equatable/equatable.dart';

import 'interview_question.dart';
import '../value_objects/localized_text.dart';

class PracticeCard extends Equatable {
  const PracticeCard({
    required this.topicId,
    required this.topicName,
    required this.question,
  });

  final String topicId;
  final LocalizedText topicName;
  final InterviewQuestion question;

  @override
  List<Object> get props => [topicId, topicName, question];
}
