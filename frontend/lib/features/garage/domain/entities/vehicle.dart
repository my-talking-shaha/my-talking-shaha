final class Vehicle {
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileageKm,
    required this.engineType,
    required this.status,
    required this.activeWarningsCount,
    this.color,
    this.photoUrl,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String? color;
  final int currentMileageKm;
  final String engineType;
  final String? photoUrl;
  final String status;
  final int activeWarningsCount;

  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? color,
    int? currentMileageKm,
    String? engineType,
    String? photoUrl,
    String? status,
    int? activeWarningsCount,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      currentMileageKm: currentMileageKm ?? this.currentMileageKm,
      engineType: engineType ?? this.engineType,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      activeWarningsCount: activeWarningsCount ?? this.activeWarningsCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Vehicle &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            brand == other.brand &&
            model == other.model &&
            year == other.year &&
            color == other.color &&
            currentMileageKm == other.currentMileageKm &&
            engineType == other.engineType &&
            photoUrl == other.photoUrl &&
            status == other.status &&
            activeWarningsCount == other.activeWarningsCount;
  }

  @override
  int get hashCode => Object.hash(
        id,
        brand,
        model,
        year,
        color,
        currentMileageKm,
        engineType,
        photoUrl,
        status,
        activeWarningsCount,
      );
}
