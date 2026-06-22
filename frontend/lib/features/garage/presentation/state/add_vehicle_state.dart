final class AddVehicleState {
  const AddVehicleState({
    this.brand = '',
    this.model = '',
    this.year = '',
    this.color = '',
    this.currentMileage = '',
    this.engineType = '',
    this.engineSpecification = '',
    this.vin = '',
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String brand;
  final String model;
  final String year;
  final String color;
  final String currentMileage;
  final String engineType;
  final String engineSpecification;
  final String vin;
  final Map<String, String> fieldErrors;
  final bool isSubmitting;
  final String? errorMessage;

  AddVehicleState copyWith({
    String? brand,
    String? model,
    String? year,
    String? color,
    String? currentMileage,
    String? engineType,
    String? engineSpecification,
    String? vin,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AddVehicleState(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      currentMileage: currentMileage ?? this.currentMileage,
      engineType: engineType ?? this.engineType,
      engineSpecification: engineSpecification ?? this.engineSpecification,
      vin: vin ?? this.vin,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
