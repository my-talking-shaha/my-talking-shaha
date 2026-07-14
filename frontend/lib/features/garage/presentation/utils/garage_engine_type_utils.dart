import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/features/garage/presentation/utils/garage_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

PopupMenuItem<String> garageEngineTypeMenuItem(
  BuildContext context,
  AppLocalizations l10n,
  String value,
) {
  return PopupMenuItem(
    value: value,
    child: Text(
      localizedGarageEngineType(l10n, value),
      style: TextStyle(color: context.appColors.textPrimary),
    ),
  );
}
