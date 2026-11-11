import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/built_quiz.dart';
import '../../domain/entities/quiz_result.dart';
import '../../../tracks/domain/entities/quiz_item.dart';
import '../../../tracks/domain/entities/track.dart';
import '../cubits/quiz_cubit.dart';
import 'quiz_screen.dart';

class QuizRetryRequest {
  const QuizRetryRequest({required this.track, required this.items});

  final InterviewTrack track;
  final List<QuizItem> items;
}

class QuizSummaryRequest {
  const QuizSummaryRequest({
    required this.track,
    required this.quiz,
    required this.result,
  });

  final InterviewTrack track;
  final BuiltQuiz quiz;
  final QuizResult result;
}

class QuizRoute extends StatefulWidget {
  const QuizRoute({required this.cubit, this.retryRequest, super.key});

  final QuizCubit cubit;
  final QuizRetryRequest? retryRequest;

  @override
  State<QuizRoute> createState() => _QuizRouteState();
}

class _QuizRouteState extends State<QuizRoute> {
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await widget.cubit.load();
    final retry = widget.retryRequest;
    if (retry != null && mounted) {
      await widget.cubit.startRetryItems(retry.track, retry.items);
    }
  }

  @override
  void dispose() {
    widget.cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: widget.cubit, child: const QuizScreen());
}
