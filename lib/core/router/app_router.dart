import 'package:flutter/material.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/quiz/presentation/cubits/quiz_cubit.dart';
import '../../features/quiz/presentation/screens/quiz_route.dart';
import '../../features/quiz/presentation/screens/quiz_summary_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tracks/presentation/cubits/practice_session_cubit.dart';
import '../../features/tracks/presentation/cubits/track_cubit.dart';
import '../../features/tracks/presentation/screens/practice_session_screen.dart';
import '../../features/tracks/presentation/screens/mock_interview_summary_screen.dart';
import '../../features/tracks/presentation/screens/track_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
  static const quiz = '/quiz';
  static const quizSummary = '/quiz/results';
  static const interview = '/interview';
  static const practiceSession = '/interview/session';
  static const mockSummary = '/interview/mock-summary';
}

class AppRouter {
  const AppRouter({
    this.createTrackCubit,
    this.createPracticeSessionCubit,
    this.createQuizCubit,
  });

  final TrackCubit Function()? createTrackCubit;
  final PracticeSessionCubit Function()? createPracticeSessionCubit;
  final QuizCubit Function()? createQuizCubit;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.quiz:
        final createCubit = createQuizCubit;
        if (createCubit == null) return null;
        final arguments = settings.arguments;
        return MaterialPageRoute<void>(
          builder:
              (_) => QuizRoute(
                cubit: createCubit(),
                retryRequest: arguments is QuizRetryRequest ? arguments : null,
              ),
          settings: settings,
        );
      case AppRoutes.quizSummary:
        final arguments = settings.arguments;
        if (arguments is! QuizSummaryRequest) return null;
        return MaterialPageRoute<void>(
          builder: (_) => QuizSummaryScreen(request: arguments),
          settings: settings,
        );
      case AppRoutes.interview:
        final createCubit = createTrackCubit;
        if (createCubit == null) return null;
        return MaterialPageRoute<void>(
          builder: (_) => TrackRoute(cubit: createCubit()),
          settings: settings,
        );
      case AppRoutes.practiceSession:
        final createCubit = createPracticeSessionCubit;
        final arguments = settings.arguments;
        if (createCubit == null || arguments is! PracticeSessionRequest) {
          return null;
        }
        return MaterialPageRoute<void>(
          builder:
              (_) => PracticeSessionRoute(
                cubit: createCubit(),
                request: arguments,
              ),
          settings: settings,
        );
      case AppRoutes.mockSummary:
        final arguments = settings.arguments;
        if (arguments is! MockInterviewSummaryRequest) return null;
        return MaterialPageRoute<void>(
          builder:
              (_) => MockInterviewSummaryScreen(
                track: arguments.track,
                summary: arguments.summary,
              ),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
