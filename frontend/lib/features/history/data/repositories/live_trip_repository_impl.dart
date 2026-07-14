import 'package:frontend/features/history/data/datasources/live_trip_activity_datasource.dart';
import 'package:frontend/features/history/data/datasources/live_trip_storage.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/repositories/live_trip_repository.dart';

final class LiveTripRepositoryImpl implements LiveTripRepository {
  const LiveTripRepositoryImpl(this._storage, this._activity);

  final LiveTripStorage _storage;
  final LiveTripActivityDatasource _activity;

  @override
  Future<LiveTripSession?> restore() async {
    final session = await _storage.read();
    if (session != null) {
      await _bestEffort(() => _activity.ensureStarted(session));
    }
    return session;
  }

  @override
  Future<void> start(LiveTripSession session) async {
    await _storage.write(session);
    await _bestEffort(() => _activity.ensureStarted(session));
  }

  @override
  Future<void> end() async {
    await _storage.clear();
    await _bestEffort(_activity.end);
  }

  Future<void> _bestEffort(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Live Activity is an enhancement; the trip session remains functional.
    }
  }
}
