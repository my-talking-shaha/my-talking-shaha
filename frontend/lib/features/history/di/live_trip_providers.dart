import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/storage/shared_preferences_provider.dart';
import 'package:frontend/features/history/data/datasources/live_trip_activity_datasource.dart';
import 'package:frontend/features/history/data/datasources/live_trip_storage.dart';
import 'package:frontend/features/history/data/repositories/live_trip_repository_impl.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/repositories/live_trip_repository.dart';
import 'package:frontend/features/history/domain/use_cases/create_live_trip_event.dart';
import 'package:frontend/features/history/presentation/controllers/live_trip_controller.dart';

final liveTripStorageProvider = Provider<LiveTripStorage>((ref) {
  return SharedPreferencesLiveTripStorage(ref.watch(sharedPreferencesProvider));
});

final liveTripActivityDatasourceProvider = Provider<LiveTripActivityDatasource>(
  (ref) => const MethodChannelLiveTripActivityDatasource(),
);

final liveTripRepositoryProvider = Provider<LiveTripRepository>((ref) {
  return LiveTripRepositoryImpl(
    ref.watch(liveTripStorageProvider),
    ref.watch(liveTripActivityDatasourceProvider),
  );
});

final createLiveTripEventProvider = Provider<CreateLiveTripEvent>(
  (ref) => const CreateLiveTripEvent(),
);

final liveTripControllerProvider =
    AsyncNotifierProvider<LiveTripController, LiveTripSession?>(
      LiveTripController.new,
      retry: (_, _) => null,
    );
