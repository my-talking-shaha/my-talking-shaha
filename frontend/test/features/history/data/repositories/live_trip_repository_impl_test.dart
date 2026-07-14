import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/live_trip_activity_datasource.dart';
import 'package:frontend/features/history/data/datasources/live_trip_storage.dart';
import 'package:frontend/features/history/data/repositories/live_trip_repository_impl.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

void main() {
  final session = LiveTripSession(
    vehicleId: 'vehicle_1',
    vehicleName: 'Lada 2107',
    startMileageKm: 120000,
    startedAt: DateTime.utc(2026, 7, 14, 10),
  );

  test('stores the trip before requesting Live Activity', () async {
    final calls = <String>[];
    final repository = LiveTripRepositoryImpl(
      _MemoryStorage(calls),
      _RecordingActivity(calls),
    );

    await repository.start(session);

    expect(calls, ['storage.write', 'activity.start']);
  });

  test('restores the session even when Live Activity is unavailable', () async {
    final storage = _MemoryStorage([])..session = session;
    final repository = LiveTripRepositoryImpl(
      storage,
      _RecordingActivity([], shouldThrow: true),
    );

    expect(await repository.restore(), session);
  });

  test(
    'clears the core session even when ending Live Activity fails',
    () async {
      final storage = _MemoryStorage([])..session = session;
      final repository = LiveTripRepositoryImpl(
        storage,
        _RecordingActivity([], shouldThrow: true),
      );

      await repository.end();

      expect(storage.session, isNull);
    },
  );
}

final class _MemoryStorage implements LiveTripStorage {
  _MemoryStorage(this.calls);

  final List<String> calls;
  LiveTripSession? session;

  @override
  Future<void> clear() async {
    calls.add('storage.clear');
    session = null;
  }

  @override
  Future<LiveTripSession?> read() async => session;

  @override
  Future<void> write(LiveTripSession value) async {
    calls.add('storage.write');
    session = value;
  }
}

final class _RecordingActivity implements LiveTripActivityDatasource {
  _RecordingActivity(this.calls, {this.shouldThrow = false});

  final List<String> calls;
  final bool shouldThrow;

  @override
  Future<void> end() async {
    calls.add('activity.end');
    if (shouldThrow) throw StateError('Unavailable');
  }

  @override
  Future<void> ensureStarted(LiveTripSession session) async {
    calls.add('activity.start');
    if (shouldThrow) throw StateError('Unavailable');
  }
}
