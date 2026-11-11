import 'package:equatable/equatable.dart';

import 'interview_question.dart';
import '../value_objects/localized_text.dart';

class InterviewTrack extends Equatable {
  const InterviewTrack({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topics,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final String icon;
  final List<InterviewTopic> topics;

  @override
  List<Object> get props => [id, name, description, icon, topics];
}

class InterviewTopic extends Equatable {
  const InterviewTopic({
    required this.id,
    required this.name,
    required this.interviewCards,
  });

  final String id;
  final LocalizedText name;
  final List<InterviewQuestion> interviewCards;

  @override
  List<Object> get props => [id, name, interviewCards];
}
