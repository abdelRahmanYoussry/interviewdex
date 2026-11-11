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
import '../../features/tracks/domain/repositories/track_repository.dart';
import '../../features/tracks/domain/use_cases/load_tracks.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton(AppRouter.new);
  }
  if (!sl.isRegistered<AnalyticsService>()) {
    sl.registerLazySingleton<AnalyticsService>(
      () => const NoOpAnalyticsService(),
    );
  }
  if (!sl.isRegistered<SettingsRepository>()) {
    final preferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SettingsRepository>(
      () => SharedPreferencesSettingsRepository(preferences),
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
}
