import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/settings/presentation/utils/settings_localization_utils.dart';
import 'package:frontend/features/settings/presentation/utils/settings_profile_utils.dart';

void main() {
  group('settings profile presentation', () {
    test('prefers and trims full name', () {
      expect(
        settingsProfileName(
          fullName: '  Test Driver  ',
          login: 'driver',
          fallback: 'Driver',
        ),
        'Test Driver',
      );
    });

    test('falls back from blank full name to login and localized label', () {
      expect(
        settingsProfileName(
          fullName: ' ',
          login: '  driver  ',
          fallback: 'Driver',
        ),
        'driver',
      );
      expect(
        settingsProfileName(fullName: null, login: ' ', fallback: 'Driver'),
        'Driver',
      );
      expect(
        settingsProfileLogin(login: ' ', fallback: 'Signed in'),
        'Signed in',
      );
    });

    test('builds at most two uppercase initials', () {
      expect(settingsInitials('Test Driver'), 'TD');
      expect(settingsInitials('test middle driver'), 'TM');
      expect(settingsInitials(' driver '), 'D');
      expect(settingsInitials(' '), '?');
    });
  });

  test('settings language code preserves the EN fallback', () {
    expect(settingsLanguageCode(const Locale('ru')), 'RU');
    expect(settingsLanguageCode(const Locale('en')), 'EN');
    expect(settingsLanguageCode(const Locale('de')), 'EN');
  });
}
