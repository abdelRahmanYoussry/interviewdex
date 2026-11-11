import 'package:get_it/get_it.dart';

import '../../features/tracks/data/data_sources/track_asset_source.dart';
import '../../features/tracks/data/repositories/track_content_loader.dart';
import '../../features/tracks/data/repositories/track_repository_impl.dart';
import '../../features/tracks/domain/repositories/track_repository.dart';
import '../../features/tracks/domain/use_cases/load_tracks.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton(AppRouter.new);
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
