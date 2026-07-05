import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/presentation/utils/chat_message_presentation.dart';
import 'package:frontend/l10n/generated/app_localizations_en.dart';
import 'package:frontend/l10n/generated/app_localizations_ru.dart';

void main() {
  test('quick questions use app locale for known backend variants', () {
    final l10n = AppLocalizationsRu();

    expect(
      quickQuestionsFromBackend(l10n, [
        'Vehicle status',
        'What are my total expenses?',
        'Какие расходы за всё время?',
        'Что может сломаться скоро?',
      ]),
      [
        'Состояние авто',
        'Какие расходы за всё время?',
        'Что может сломаться скоро?',
      ],
    );
  });

  test(
    'localized backend text maps Russian quick questions to English locale',
    () {
      final l10n = AppLocalizationsEn();

      expect(
        localizedBackendChatText(l10n, 'Какие расходы за всё время?'),
        'What are my total expenses?',
      );
    },
  );
}
