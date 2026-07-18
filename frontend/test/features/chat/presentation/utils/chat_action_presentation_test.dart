import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/presentation/utils/chat_action_presentation.dart';

void main() {
  const vehicleId = 'vehicle-1';

  test('screen actions preserve shell destination and chat return marker', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(type: 'OPEN_SCREEN', screen: 'ANALYTICS', prefill: {}),
      ),
      '/vehicle/vehicle-1/analytics?from=chat',
    );
  });

  test('form actions preserve all supported prefill values', () {
    final destination = chatActionDestination(
      vehicleId,
      const ChatAction(
        type: 'OPEN_FORM',
        form: 'REFUEL',
        prefill: {
          'mileageKm': 15000,
          'liters': 5.5,
          'cost': 1000,
          'fuelName': '95 octane',
          'stationName': 'Test station',
          'ignored': 'not forwarded',
        },
      ),
    );

    final uri = Uri.parse(destination!);
    expect(uri.path, '/vehicle/vehicle-1/history/add');
    expect(uri.queryParameters, {
      'type': 'fuel',
      'from': 'chat',
      'mileageKm': '15000',
      'liters': '5.5',
      'cost': '1000',
      'fuelName': '95 octane',
      'stationName': 'Test station',
    });
  });

  test('created event action opens the matching history editor', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(
          type: 'OPEN_SCREEN',
          screen: 'HISTORY_EVENT_EDIT',
          prefill: {'eventId': 'event-42', 'eventType': 'MAINTENANCE'},
        ),
      ),
      '/vehicle/vehicle-1/history/event-42/edit?from=chat',
    );
  });

  test('event actions without a target id remain hidden', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(
          type: 'OPEN_SCREEN',
          screen: 'HISTORY_EVENT_EDIT',
          prefill: {},
        ),
      ),
      isNull,
    );
  });

  test('unsupported actions remain hidden', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(type: 'UNKNOWN', prefill: {}),
      ),
      isNull,
    );
  });

  test('unsupported forms remain hidden', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(type: 'OPEN_FORM', form: 'UNKNOWN', prefill: {}),
      ),
      isNull,
    );
  });
}
