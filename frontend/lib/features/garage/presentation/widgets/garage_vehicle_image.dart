import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';

final class GarageVehicleImage extends StatelessWidget {
  const GarageVehicleImage({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final photoUrl = vehicle.photoUrl?.trim();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.md),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: photoUrl == null || photoUrl.isEmpty
            ? Container(
                key: ValueKey('garage_vehicle_photo_fallback_${vehicle.id}'),
                decoration: BoxDecoration(
                  color: context.appColors.backgroundDark,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.appColors.primaryPressed.withValues(alpha: 0.34),
                      context.appColors.primarySoft.withValues(alpha: 0.94),
                      context.appColors.backgroundDark,
                    ],
                    stops: const [0, 0.56, 1],
                  ),
                  border: Border(
                    bottom: BorderSide(color: context.appColors.border),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.22),
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.appColors.primaryLight,
                            context.appColors.primaryPressed,
                          ],
                        ).createShader(bounds),
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          color: context.appColors.white,
                          size: 92,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Image.network(photoUrl, fit: BoxFit.cover),
      ),
    );
  }
}
