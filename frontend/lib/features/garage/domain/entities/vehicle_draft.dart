final class VehicleDraft {
  const VehicleDraft({
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileageKm,
    required this.engineType,
    required this.engineVolumeLiters,
    required this.enginePowerHp,
    this.color,
    this.vin,
  });

  final String brand;
  final String model;
  final int year;
  final String? color;
  final int currentMileageKm;
  final String engineType;
  final double? engineVolumeLiters;
  final int? enginePowerHp;
  final String? vin;

  VehicleDraft trimmed() {
    final trimmedColor = color?.trim();
    final trimmedVin = vin?.trim().toUpperCase();

    return VehicleDraft(
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      color: trimmedColor == null || trimmedColor.isEmpty ? null : trimmedColor,
      currentMileageKm: currentMileageKm,
      engineType: engineType.trim(),
      engineVolumeLiters: engineVolumeLiters,
      enginePowerHp: enginePowerHp,
      vin: trimmedVin == null || trimmedVin.isEmpty ? null : trimmedVin,
    );
  }
}
