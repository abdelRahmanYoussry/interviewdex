import 'package:equatable/equatable.dart';

class SavedQuizSession extends Equatable {
  const SavedQuizSession({
    required this.trackId,
    required this.itemIds,
    required this.index,
    required this.answers,
    required this.optionOrders,
    this.topicId,
  });

  final String trackId;
  final String? topicId;
  final List<String> itemIds;
  final int index;
  final Map<String, int> answers;
  final Map<String, List<int>> optionOrders;

  @override
  List<Object?> get props => [
    trackId,
    topicId,
    itemIds,
    index,
    answers,
    optionOrders,
  ];
}
