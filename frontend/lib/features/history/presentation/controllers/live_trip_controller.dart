import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/history/di/live_trip_providers.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

final class LiveTripController extends AsyncNotifier<LiveTripSession?> {
  @override
  Future<LiveTripSession?> build() {
    return ref.watch(liveTripRepositoryProvider).restore();
  }

  Future<LiveTripSession> start({
    required String vehicleId,
    required String vehicleName,
    required int startMileageKm,
    DateTime? startedAt,
  }) async {
    if (state.isLoading) {
      throw StateError('A live trip operation is already in progress.');
    }

    final current = state.value;
    if (current != null) {
      if (current.vehicleId != vehicleId) {
        throw LiveTripAlreadyActiveException(current);
      }
      return current;
    }

    final session = LiveTripSession(
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      startMileageKm: startMileageKm,
      startedAt: startedAt ?? DateTime.now(),
    );
    state = const AsyncLoading();
    try {
      await ref.read(liveTripRepositoryProvider).start(session);
      state = AsyncData(session);
      return session;
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<void> end() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    try {
      await ref.read(liveTripRepositoryProvider).end();
      state = const AsyncData(null);
    } catch (_) {
      // The trip was already saved by the caller. Keep it closed in memory to
      // prevent an accidental duplicate submission if local cleanup fails.
      state = const AsyncData(null);
      rethrow;
    }
  }
}

final class LiveTripAlreadyActiveException implements Exception {
  const LiveTripAlreadyActiveException(this.session);

  final LiveTripSession session;
}
