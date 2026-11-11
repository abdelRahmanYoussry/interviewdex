import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/no_op_analytics_service.dart';
import '../../features/settings/data/shared_preferences_settings_repository.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/presentation/settings_cubit.dart';
import '../../features/tracks/data/data_sources/track_asset_source.dart';
import '../../features/tracks/data/repositories/track_content_loader.dart';
import '../../features/tracks/data/repositories/track_repository_impl.dart';
import '../../features/tracks/data/repositories/shared_preferences_practice_progress_repository.dart';
import '../../features/tracks/domain/repositories/practice_progress_repository.dart';
import '../../features/tracks/domain/repositories/track_repository.dart';
import '../../features/tracks/domain/use_cases/load_tracks.dart';
import '../../features/tracks/domain/use_cases/build_mock_interview.dart';
import '../../features/tracks/domain/use_cases/spaced_repetition.dart';
import '../../features/tracks/domain/use_cases/summarize_mock_interview.dart';
import '../../features/tracks/presentation/cubits/practice_session_cubit.dart';
import '../../features/tracks/presentation/cubits/track_cubit.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton(
      () => AppRouter(
        createTrackCubit: () => sl<TrackCubit>(),
        createPracticeSessionCubit: () => sl<PracticeSessionCubit>(),
      ),
    );
  }
  if (!sl.isRegistered<AnalyticsService>()) {
    sl.registerLazySingleton<AnalyticsService>(
      () => const NoOpAnalyticsService(),
    );
  }
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton(await SharedPreferences.getInstance());
  }
  if (!sl.isRegistered<SettingsRepository>()) {
    sl.registerLazySingleton<SettingsRepository>(
      () => SharedPreferencesSettingsRepository(sl<SharedPreferences>()),
    );
    sl.registerFactory(() => SettingsCubit(sl<SettingsRepository>()));
  }
  if (!sl.isRegistered<TrackAssetSource>()) {
    sl.registerLazySingleton<TrackAssetSource>(
      () => const FlutterTrackAssetSource(),
    );
  }
  if (!sl.isRegistered<TrackContentLoader>()) {
    sl.registerLazySingleton<TrackContentLoader>(
      () => TrackContentLoader(assetSource: sl<TrackAssetSource>()),
    );
  }
  if (!sl.isRegistered<TrackRepository>()) {
    sl.registerLazySingleton<TrackRepository>(
      () => TrackRepositoryImpl(sl<TrackContentLoader>()),
    );
  }
  if (!sl.isRegistered<LoadTracks>()) {
    sl.registerLazySingleton(() => LoadTracks(sl<TrackRepository>()));
  }
  if (!sl.isRegistered<PracticeProgressRepository>()) {
    sl.registerLazySingleton<PracticeProgressRepository>(
      () =>
          SharedPreferencesPracticeProgressRepository(sl<SharedPreferences>()),
    );
  }
  if (!sl.isRegistered<TrackCubit>()) {
    sl.registerFactory(
      () => TrackCubit(
        loadTracks: sl<LoadTracks>(),
        progressRepository: sl<PracticeProgressRepository>(),
        analytics: sl<AnalyticsService>(),
      ),
    );
  }
  if (!sl.isRegistered<SpacedRepetition>()) {
    sl.registerLazySingleton(() => const SpacedRepetition());
  }
  if (!sl.isRegistered<BuildMockInterview>()) {
    sl.registerLazySingleton(() => const BuildMockInterview());
  }
  if (!sl.isRegistered<SummarizeMockInterview>()) {
    sl.registerLazySingleton(() => const SummarizeMockInterview());
  }
  if (!sl.isRegistered<PracticeSessionCubit>()) {
    sl.registerFactory(
      () => PracticeSessionCubit(
        loadTracks: sl<LoadTracks>(),
        progressRepository: sl<PracticeProgressRepository>(),
        spacedRepetition: sl<SpacedRepetition>(),
        buildMockInterview: sl<BuildMockInterview>(),
        summarizeMockInterview: sl<SummarizeMockInterview>(),
        analytics: sl<AnalyticsService>(),
      ),
    );
  }
}
