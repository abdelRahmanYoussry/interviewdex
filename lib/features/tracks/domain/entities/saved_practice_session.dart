import 'package:equatable/equatable.dart';

enum PracticeMode { topic, mock }

class SavedPracticeSession extends Equatable {
  const SavedPracticeSession({
    required this.mode,
    required this.cardIds,
    required this.index,
    required this.revealed,
    this.topicId,
    this.retriedCardIds = const {},
  });

  final PracticeMode mode;
  final List<String> cardIds;
  final int index;
  final bool revealed;
  final String? topicId;
  final Set<String> retriedCardIds;

  @override
  List<Object?> get props => [
    mode,
    cardIds,
    index,
    revealed,
    topicId,
    retriedCardIds,
  ];
}
