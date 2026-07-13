import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

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
                  color: GarageColors.backgroundDark,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GarageColors.primaryPressed.withValues(alpha: 0.34),
                      GarageColors.primarySoft.withValues(alpha: 0.94),
                      GarageColors.backgroundDark,
                    ],
                    stops: const [0, 0.56, 1],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: GarageColors.border),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.22),
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            GarageColors.primaryLight,
                            GarageColors.primaryPressed,
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: GarageColors.white,
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
