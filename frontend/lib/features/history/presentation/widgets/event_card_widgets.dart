part of 'event_card.dart';

class _PhotoToggle extends StatelessWidget {
  final int count;
  final bool isExpanded;

  const _PhotoToggle({required this.count, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
        borderRadius: AppRadius.input,
      ),
      child: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 16,
            color: context.appColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '${l10n.partPhotoLabel} $count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.appColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

final class _HistorySwipeRevealActions extends StatefulWidget {
  const _HistorySwipeRevealActions({
    required this.child,
    required this.actions,
  });

  final Widget child;
  final List<Widget> actions;

  @override
  State<_HistorySwipeRevealActions> createState() =>
      _HistorySwipeRevealActionsState();
}

final class _HistorySwipeRevealActionsState
    extends State<_HistorySwipeRevealActions> {
  static const double _actionWidth = 120;
  double _dragOffset = 0;

  bool get _isOpen => _dragOffset < 0;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dx).clamp(
            -_actionWidth,
            0,
          );
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _dragOffset = _dragOffset.abs() > _actionWidth * 0.38
              ? -_actionWidth
              : 0;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (
                      var index = 0;
                      index < widget.actions.length;
                      index++
                    ) ...[
                      widget.actions[index],
                      if (index < widget.actions.length - 1)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: GestureDetector(
              onTap: _isOpen
                  ? () {
                      setState(() {
                        _dragOffset = 0;
                      });
                    }
                  : null,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

final class _HistorySwipeActionButton extends StatelessWidget {
  const _HistorySwipeActionButton({
    required this.actionKey,
    required this.label,
    required this.iconPath,
    required this.color,
    required this.onPressed,
  });

  final String actionKey;
  final String label;
  final String iconPath;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox.square(
        dimension: 52,
        child: IconButton.filled(
          key: ValueKey('history_swipe_action_$actionKey'),
          onPressed: onPressed,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: context.appColors.white,
            shape: const CircleBorder(),
          ),
          icon: SvgPicture.asset(
            iconPath,
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              context.appColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventPhotoList extends StatelessWidget {
  final List<String> urls;

  const _EventPhotoList({required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('event-photo-list'),
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return SizedBox.square(
            dimension: 104,
            child: GestureDetector(
              key: ValueKey('event-photo-open-$index'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _openPhotoPreview(context, urls, index),
              child: _EventPhoto(url: urls[index]),
            ),
          );
        },
      ),
    );
  }

  void _openPhotoPreview(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    unawaited(
      showNativeFullscreenModal<void>(
        context: context,
        backgroundColor: context.appColors.background,
        builder: (context) =>
            _EventPhotoPreview(urls: urls, initialIndex: initialIndex),
      ),
    );
  }
}

class _EventPhotoPreview extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _EventPhotoPreview({required this.urls, required this.initialIndex});

  @override
  State<_EventPhotoPreview> createState() => _EventPhotoPreviewState();
}

class _EventPhotoPreviewState extends State<_EventPhotoPreview> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('event-photo-preview'),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image(
                    image: _eventPhotoImageProvider(widget.urls[index]),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image_outlined,
                      color: context.appColors.textMuted,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: IconButton.filled(
              key: const ValueKey('event-photo-preview-close'),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: context.appColors.surface.withValues(
                  alpha: 0.88,
                ),
                foregroundColor: context.appColors.textPrimary,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColors.surface.withValues(alpha: 0.88),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.urls.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventIcon extends StatelessWidget {
  final _EventPresentation presentation;

  const _EventIcon({required this.presentation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: presentation.iconBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SvgPicture.asset(
        presentation.iconAsset,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(presentation.iconColor, BlendMode.srcIn),
      ),
    );
  }
}

class _EventTimestamp extends StatelessWidget {
  final DateTime occurredAt;

  const _EventTimestamp({required this.occurredAt});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 14, color: context.appColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            _formatDateTime(context, occurredAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _EventPhoto extends StatelessWidget {
  final String url;

  const _EventPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image(
        image: _eventPhotoImageProvider(url),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: context.appColors.surfaceElevated,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: context.appColors.textMuted,
          ),
        ),
      ),
    );
  }
}

ImageProvider _eventPhotoImageProvider(String url) {
  final uri = Uri.tryParse(url);
  final isRemote = uri?.scheme == 'http' || uri?.scheme == 'https';
  return isRemote ? NetworkImage(url) : FileImage(File(url));
}

class _EventPresentation {
  final String iconAsset;
  final Color iconColor;
  final Color iconBackground;
  final String? metric;

  const _EventPresentation({
    required this.iconAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.metric,
  });

  factory _EventPresentation.from(BuildContext context, HistoryEvent event) {
    return switch (event.type) {
      HistoryEventType.fuel => _EventPresentation(
        iconAsset: _isChargeFuelDetails(event.details)
            ? 'assets/icons/events/charge.svg'
            : 'assets/icons/events/gas.svg',
        iconColor: context.appColors.primary,
        iconBackground: context.appColors.primarySoft,
        metric: event.details is FuelDetails
            ? '${_formatNumber((event.details as FuelDetails).cost)} ₽'
            : null,
      ),
      HistoryEventType.maintenance => _EventPresentation(
        iconAsset: 'assets/icons/events/spanner.svg',
        iconColor: context.appColors.error,
        iconBackground: context.appColors.error.withValues(alpha: 0.14),
        metric: switch (event.details) {
          MaintenanceDetails(cost: final cost?) => '${_formatNumber(cost)} ₽',
          _ => null,
        },
      ),
      HistoryEventType.part => _EventPresentation(
        iconAsset: 'assets/icons/parts/maintenance.svg',
        iconColor: context.appColors.error,
        iconBackground: context.appColors.error.withValues(alpha: 0.14),
        metric: switch (event.details) {
          MaintenanceDetails(cost: final cost?) => '${_formatNumber(cost)} ₽',
          _ => null,
        },
      ),
      HistoryEventType.trip => _EventPresentation(
        iconAsset: 'assets/icons/events/trip.svg',
        iconColor: context.appColors.textSecondary,
        iconBackground: context.appColors.surfaceElevated,
        metric: event.details is TripDetails
            ? '${_formatNumber((event.details as TripDetails).distanceKm)} km'
            : null,
      ),
    };
  }
}

bool _isChargeFuelDetails(EventDetails details) {
  if (details is! FuelDetails) return false;
  if (details.isRecharge) return true;

  final fuelType = details.fuelType.toLowerCase();
  return fuelType.contains('charging') ||
      fuelType.contains('charger') ||
      fuelType.contains('supercharger') ||
      fuelType.contains('electric') ||
      fuelType.contains('kwh') ||
      fuelType.contains('квт');
}

String _formatFuelAmount(FuelDetails details) {
  final unit = details.isRecharge ? 'kWh' : 'L';
  return '${_formatDecimal(details.liters)} $unit';
}

String _formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[index]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}

String _formatDecimal(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

String _formatDuration(BuildContext context, Duration duration) {
  final isRu = Localizations.localeOf(context).languageCode == 'ru';
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) return isRu ? '$minutes мин' : '$minutes min';
  if (minutes == 0) return isRu ? '$hours ч' : '$hours h';
  return isRu ? '$hours ч $minutes мин' : '$hours h $minutes min';
}

String _formatDateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  if (Localizations.localeOf(context).languageCode == 'en') {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, $hour:$minute';
  }

  final date = MaterialLocalizations.of(context).formatMediumDate(local);
  final time = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true);

  return '$date, $time';
}
