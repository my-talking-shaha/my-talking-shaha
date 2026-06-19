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
    final subtitle = vehicle.color == null || vehicle.color!.isEmpty
        ? '${vehicle.year} · ${vehicle.engineType}'
        : '${vehicle.year} · ${vehicle.color} · ${vehicle.engineType}';

    return _SwipeRevealActions(
      actions: [
        if (onEdit != null)
          _SwipeActionButton(
            label: 'Edit',
            iconPath: 'assets/icons/garage/edit.svg',
            color: const Color(0xFFDCA249),
            onPressed: onEdit!,
          ),
        if (onDelete != null)
          _SwipeActionButton(
            label: 'Delete',
            iconPath: 'assets/icons/garage/delete.svg',
            color: const Color(0xFFD4352F),
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
              border: Border.all(color: AppColors.border),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceHighest, AppColors.surface],
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
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/mileage.svg',
                              label: 'MILEAGE',
                              value:
                                  '${_formatMileage(vehicle.currentMileageKm)} km',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/repair.svg',
                              label: 'SERVICE',
                              value: vehicle.activeWarningsCount > 0
                                  ? '${vehicle.activeWarningsCount} warnings'
                                  : 'No issues',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: _MetricTile(
                              iconPath: 'assets/icons/garage/refuel.svg',
                              label: 'FUEL',
                              value: 'No data',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onOpen,
                          icon: const Icon(Icons.keyboard_arrow_right),
                          label: const Text('Open cockpit'),
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
    required this.iconPath,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String iconPath;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: IconButton.filled(
              tooltip: label,
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: photoUrl == null || photoUrl.isEmpty
            ? Container(
                key: ValueKey('garage_vehicle_photo_fallback_${vehicle.id}'),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car_filled,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
              )
            : Image.network(photoUrl, fit: BoxFit.cover),
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
