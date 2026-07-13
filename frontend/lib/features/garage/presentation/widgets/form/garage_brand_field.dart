import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/features/garage/presentation/utils/garage_input_decoration.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_field_label.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageBrandField extends StatelessWidget {
  const GarageBrandField({
    required this.controller,
    required this.focusNode,
    required this.brands,
    required this.isLoading,
    required this.onChanged,
    required this.onRetry,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> brands;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onRetry;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GarageFieldLabel(label: l10n.brand),
        const SizedBox(height: 10),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          displayStringForOption: (brand) => brand,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<String>.empty();
            }

            return brands.where((brand) => brand.toLowerCase().contains(query));
          },
          onSelected: onChanged,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 16,
                  ),
                  cursorColor: context.appColors.primaryLight,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: garageInputDecoration(
                    context: context,
                    hintText: 'Lada',
                    errorText: errorText,
                    suffixIcon: _GarageBrandSuffixIcon(
                      isLoading: isLoading,
                      hasLoadError: errorText == 'Could not load brands',
                      onRetry: onRetry,
                    ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onFieldSubmitted(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return _GarageAutocompleteOptions(
              options: options,
              onSelected: onSelected,
            );
          },
        ),
      ],
    );
  }
}

final class _GarageBrandSuffixIcon extends StatelessWidget {
  const _GarageBrandSuffixIcon({
    required this.isLoading,
    required this.hasLoadError,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasLoadError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (hasLoadError) {
      return IconButton(
        onPressed: onRetry,
        icon: Icon(Icons.refresh, color: context.appColors.primaryLight),
      );
    }

    return Icon(Icons.search, color: context.appColors.primaryLight);
  }
}

final class _GarageAutocompleteOptions extends StatelessWidget {
  const _GarageAutocompleteOptions({
    required this.options,
    required this.onSelected,
  });

  final Iterable<String> options;
  final AutocompleteOnSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: context.appColors.formField,
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220, maxWidth: 480),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final brand = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(brand),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    brand,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
