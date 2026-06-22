enum PartResourceStatus { ok, warning, critical, unknown }

final class VehiclePart {
  const VehiclePart({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.catalogKey,
    required this.installedAt,
    required this.installedAtMileageKm,
    required this.lifetimeKm,
    this.remainingKm,
    this.remainingPercent,
    this.status = PartResourceStatus.unknown,
  });

  final String id;
  final String vehicleId;
  final String name;
  final String? catalogKey;
  final DateTime installedAt;
  final int installedAtMileageKm;
  final int? lifetimeKm;
  final int? remainingKm;
  final int? remainingPercent;
  final PartResourceStatus status;

  VehiclePart withResource({
    required int? remainingKm,
    required int? remainingPercent,
    required PartResourceStatus status,
  }) {
    return VehiclePart(
      id: id,
      vehicleId: vehicleId,
      name: name,
      catalogKey: catalogKey,
      installedAt: installedAt,
      installedAtMileageKm: installedAtMileageKm,
      lifetimeKm: lifetimeKm,
      remainingKm: remainingKm,
      remainingPercent: remainingPercent,
      status: status,
    );
  }
}
