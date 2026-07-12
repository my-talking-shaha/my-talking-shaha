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

  test('form actions preserve type and mileage prefill', () {
    expect(
      chatActionDestination(
        vehicleId,
        const ChatAction(
          type: 'OPEN_FORM',
          form: 'PART_REPLACEMENT',
          prefill: {'mileageKm': 15000},
        ),
      ),
      '/vehicle/vehicle-1/history/add?type=maintenance&mileageKm=15000',
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
}
