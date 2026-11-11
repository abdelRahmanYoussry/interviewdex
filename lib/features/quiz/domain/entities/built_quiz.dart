import 'package:equatable/equatable.dart';

import '../../../tracks/domain/entities/quiz_item.dart';

class BuiltQuiz extends Equatable {
  const BuiltQuiz({
    required this.trackId,
    required this.topicId,
    required this.items,
    required this.optionOrders,
  });

  final String trackId;
  final String? topicId;
  final List<QuizItem> items;
  final Map<String, List<int>> optionOrders;

  @override
  List<Object?> get props => [trackId, topicId, items, optionOrders];
}
