import 'package:frontend/features/garage/presentation/utils/garage_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

String garageEngineTypeLabel(AppLocalizations l10n, String value) {
  if (l10n.localeName.startsWith('en')) {
    return value;
  }

  final normalizedValue = value.toLowerCase();
  const localizedValues = {'gasoline', 'diesel', 'hybrid', 'phev', 'electric'};
  if (!localizedValues.contains(normalizedValue)) {
    return value;
  }

  return localizedGarageEngineType(l10n, normalizedValue);
}

String formatGarageMileage(int mileage) {
  return mileage.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
