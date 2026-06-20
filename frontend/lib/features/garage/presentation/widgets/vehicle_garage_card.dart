import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';

final class VehicleGarageCard extends StatelessWidget {
  const VehicleGarageCard({
    required this.vehicle,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Vehicle vehicle;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = _vehicleSubtitle(vehicle);
    final meta = _vehicleMeta(vehicle);

    return _SwipeRevealActions(
      actions: [
        if (onEdit != null)
          _SwipeActionButton(
            label: 'Редактировать',
            actionId: 'edit',
            iconPath: 'assets/icons/garage/edit.svg',
            color: AppColors.warning,
            onPressed: onEdit!,
          ),
        if (onDelete != null)
          _SwipeActionButton(
            label: 'Удалить',
            actionId: 'delete',
            iconPath: 'assets/icons/garage/delete.svg',
            color: AppColors.error,
            onPressed: onDelete!,
          ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppRadius.card,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.18),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surfaceHigh, AppColors.surface],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VehicleImage(vehicle: vehicle),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.brand} ${vehicle.model}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        height: 1.08,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  meta,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/mileage.svg',
                              label: 'Пробег',
                              value:
                                  '${_formatMileage(vehicle.currentMileageKm)} км',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/repair.svg',
                              label: 'Сервис',
                              value: vehicle.activeWarningsCount > 0
                                  ? '${vehicle.activeWarningsCount} замеч.'
                                  : 'без замеч.',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/refuel.svg',
                              label: 'Топливо',
                              value: 'нет данных',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onOpen,
                          label: const Text('В кабину'),
                          icon: const Icon(Icons.arrow_forward, size: 22),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SwipeRevealActions extends StatefulWidget {
  const _SwipeRevealActions({required this.child, required this.actions});

  final Widget child;
  final List<Widget> actions;

  @override
  State<_SwipeRevealActions> createState() => _SwipeRevealActionsState();
}

final class _SwipeRevealActionsState extends State<_SwipeRevealActions> {
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
          _dragOffset =
              _dragOffset.abs() > _actionWidth * 0.38 ? -_actionWidth : 0;
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.actions,
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

final class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.label,
    required this.actionId,
    required this.iconPath,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String actionId;
  final String iconPath;
  final Color color;
  final VoidCallback onPressed;

  String get _actionKey => 'garage_swipe_action_$actionId';

  static const _labelStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: IconButton.filled(
                key: ValueKey(_actionKey),
                onPressed: onPressed,
                style: IconButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppColors.white,
                  shape: const CircleBorder(),
                ),
                icon: SvgPicture.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: _labelStyle),
          ],
        ),
      ),
    );
  }
}

final class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final photoUrl = vehicle.photoUrl;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: photoUrl == null || photoUrl.isEmpty
            ? _VehicleFallbackImage(
                key: ValueKey('garage_vehicle_photo_fallback_${vehicle.id}'),
              )
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _VehicleFallbackImage(
                  key: ValueKey('garage_vehicle_photo_error_${vehicle.id}'),
                ),
              ),
      ),
    );
  }
}

final class _VehicleFallbackImage extends StatelessWidget {
  const _VehicleFallbackImage({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SvgPicture.asset(
        'assets/images/garage_car_placeholder.svg',
        fit: BoxFit.cover,
      ),
    );
  }
}

final class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  final String iconPath;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.32)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 14, height: 14),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    height: 1.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMileage(int mileage) {
  return mileage.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}

String _vehicleSubtitle(Vehicle vehicle) {
  if (vehicle.activeWarningsCount > 0) {
    return 'ТРЕБУЕТ ВНИМАНИЯ';
  }

  return switch (vehicle.status) {
    'ok' => 'НА ХОДУ',
    'warning' => 'ТРЕБУЕТ ВНИМАНИЯ',
    'critical' => 'СРОЧНЫЙ РЕМОНТ',
    _ => 'РАБОЧАЯ ЛОШАДКА',
  };
}

String _vehicleMeta(Vehicle vehicle) {
  final color = vehicle.color;
  final parts = [
    vehicle.year.toString(),
    if (color != null && color.isNotEmpty) color,
    vehicle.engineType,
  ];

  return parts.join(' · ');
}
