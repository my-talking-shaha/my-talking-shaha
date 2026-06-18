final class VehicleDraft {
  const VehicleDraft({
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileageKm,
    required this.engineType,
    this.color,
  });

  final String brand;
  final String model;
  final int year;
  final String? color;
  final int currentMileageKm;
  final String engineType;

  VehicleDraft trimmed() {
    final trimmedColor = color?.trim();

    return VehicleDraft(
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      color: trimmedColor == null || trimmedColor.isEmpty ? null : trimmedColor,
      currentMileageKm: currentMileageKm,
      engineType: engineType.trim(),
    );
  }
}
