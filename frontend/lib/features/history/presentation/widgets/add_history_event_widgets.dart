part of '../screens/add_history_event_screen.dart';

final class _EventTypeSelector extends StatelessWidget {
  const _EventTypeSelector({
    required this.selectedType,
    required this.onSelected,
    this.isElectricVehicle = false,
    this.enabled = true,
  });

  final HistoryEventType selectedType;
  final ValueChanged<HistoryEventType> onSelected;
  final bool isElectricVehicle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (
        HistoryEventType.fuel,
        isElectricVehicle ? l10n.rechargeEvent : l10n.fuelEvent,
        isElectricVehicle
            ? 'assets/icons/events/charge.svg'
            : 'assets/icons/events/gas.svg',
      ),
      (
        HistoryEventType.maintenance,
        l10n.maintenanceEvent,
        'assets/icons/events/spanner.svg',
      ),
      (HistoryEventType.trip, l10n.tripEvent, 'assets/icons/events/trip.svg'),
    ];

    return Container(
      height: 58,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: AnimatedAlign(
              key: const ValueKey('event-type-selection'),
              alignment: switch (selectedType) {
                HistoryEventType.fuel => Alignment.centerLeft,
                HistoryEventType.maintenance => Alignment.center,
                HistoryEventType.trip => Alignment.centerRight,
              },
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / options.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColors.primaryPressed.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: AppRadius.input,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (type, label, asset) in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: type == selectedType,
                    label: label,
                    child: InkWell(
                      key: ValueKey('event-type-${type.name}'),
                      onTap: enabled ? () => onSelected(type) : null,
                      borderRadius: AppRadius.input,
                      child: Center(
                        child: SvgPicture.asset(
                          asset,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            type == selectedType
                                ? context.appColors.primary
                                : context.appColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border.all(color: context.appColors.border),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(label)),
              if (optional)
                Text(
                  AppLocalizations.of(context).optional,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

final class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(fontSize: 10, letterSpacing: 0.65),
    );
  }
}

final class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

final class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.hintText,
    this.suffixText,
    this.icon,
    this.validator,
    this.allowDecimal = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        allowDecimal
            ? FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixText: suffixText,
      ),
      validator: validator,
    );
  }
}

final class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.background,
      borderRadius: AppRadius.input,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.input,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: context.appColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

final class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.primarySoft,
        border: Border.all(
          color: context.appColors.primaryPressed.withValues(alpha: 0.4),
        ),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.appColors.primary, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.existingPhotoUrls,
    required this.photos,
    required this.isPicking,
    required this.onPick,
    required this.onRemove,
    required this.onRemoveExisting,
  });

  final List<String> existingPhotoUrls;
  final List<XFile> photos;
  final bool isPicking;
  final VoidCallback onPick;
  final ValueChanged<XFile> onRemove;
  final ValueChanged<String> onRemoveExisting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _FormCard(
      label: l10n.partPhoto,
      optional: true,
      child: existingPhotoUrls.isEmpty && photos.isEmpty
          ? OutlinedButton.icon(
              key: const ValueKey('maintenance-photo-add'),
              onPressed: isPicking ? null : onPick,
              icon: isPicking
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline, size: 18),
              label: Text(isPicking ? l10n.openingGallery : l10n.addPhoto),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  key: const ValueKey('maintenance-photo-list'),
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: existingPhotoUrls.length + photos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index < existingPhotoUrls.length) {
                        final url = existingPhotoUrls[index];
                        return _PhotoPreviewTile(
                          key: ValueKey(
                            'maintenance-existing-photo-tile-$index',
                          ),
                          removeKey: ValueKey(
                            'maintenance-existing-photo-remove-$index',
                          ),
                          onRemove: () => onRemoveExisting(url),
                          child: _ExistingHistoryPhoto(
                            url: url,
                            key: ValueKey(
                              'maintenance-existing-photo-preview-$index',
                            ),
                          ),
                        );
                      }

                      final photoIndex = index - existingPhotoUrls.length;
                      final photo = photos[photoIndex];

                      return _PhotoPreviewTile(
                        key: ValueKey('maintenance-photo-tile-$photoIndex'),
                        removeKey: ValueKey(
                          'maintenance-photo-remove-$photoIndex',
                        ),
                        onRemove: () => onRemove(photo),
                        child: Image.file(
                          File(photo.path),
                          key: ValueKey(
                            'maintenance-photo-preview-$photoIndex',
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: context.appColors.surfaceElevated,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: context.appColors.textMuted,
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  key: const ValueKey('maintenance-photo-add-more'),
                  onPressed: isPicking ? null : onPick,
                  icon: isPicking
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                  label: Text(l10n.addPhoto),
                ),
              ],
            ),
    );
  }
}

final class _PhotoPreviewTile extends StatelessWidget {
  const _PhotoPreviewTile({
    required this.child,
    required this.removeKey,
    required this.onRemove,
    super.key,
  });

  final Widget child;
  final Key removeKey;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: AppRadius.input, child: child),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: IconButton.filled(
              key: removeKey,
              onPressed: onRemove,
              tooltip: l10n.removePhoto,
              style: IconButton.styleFrom(
                backgroundColor: context.appColors.background.withValues(
                  alpha: 0.82,
                ),
                foregroundColor: context.appColors.textPrimary,
                minimumSize: const Size.square(32),
                fixedSize: const Size.square(32),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ExistingHistoryPhoto extends StatelessWidget {
  const _ExistingHistoryPhoto({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final isRemote = uri?.scheme == 'http' || uri?.scheme == 'https';
    final imageProvider = isRemote
        ? NetworkImage(url) as ImageProvider
        : FileImage(File(url));

    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: context.appColors.surfaceElevated,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: context.appColors.textMuted,
        ),
      ),
    );
  }
}
