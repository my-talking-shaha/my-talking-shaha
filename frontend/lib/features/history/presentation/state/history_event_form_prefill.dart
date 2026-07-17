final class HistoryEventFormPrefill {
  const HistoryEventFormPrefill({
    this.occurredAt,
    this.title,
    this.mileageKm,
    this.currentMileageKm,
    this.amount,
    this.cost,
    this.fuelOrChargerType,
    this.stationName,
    this.description,
    this.replacedParts,
    this.tripStartMileageKm,
    this.tripEndMileageKm,
    this.distanceKm,
    this.route,
    this.durationMinutes,
  });

  final DateTime? occurredAt;
  final String? title;
  final int? mileageKm;
  final int? currentMileageKm;
  final double? amount;
  final int? cost;
  final String? fuelOrChargerType;
  final String? stationName;
  final String? description;
  final String? replacedParts;
  final int? tripStartMileageKm;
  final int? tripEndMileageKm;
  final int? distanceKm;
  final String? route;
  final int? durationMinutes;

  factory HistoryEventFormPrefill.fromQueryParameters(
    Map<String, String> query,
  ) {
    return HistoryEventFormPrefill(
      occurredAt: DateTime.tryParse(query['eventDateTime'] ?? '')?.toLocal(),
      title: _firstText(query, const [
        'title',
        'name',
        'partName',
        'part',
        'serviceType',
      ]),
      mileageKm: _firstInt(query, const ['mileageKm']),
      currentMileageKm: _firstInt(query, const ['currentMileageKm']),
      amount: _firstDouble(query, const ['liters', 'energyKwh', 'kwh']),
      cost: _firstInt(query, const ['cost']),
      fuelOrChargerType: _firstText(query, const [
        'fuelName',
        'chargerType',
        'fuelType',
      ]),
      stationName: _firstText(query, const ['stationName']),
      description: _firstText(query, const ['description', 'repairText']),
      replacedParts: _firstText(query, const ['replacedParts']),
      tripStartMileageKm: _firstInt(query, const ['startMileageKm']),
      tripEndMileageKm: _firstInt(query, const ['endMileageKm']),
      distanceKm: _firstInt(query, const ['distanceKm']),
      route: _firstText(query, const ['route']),
      durationMinutes: _firstInt(query, const ['durationMinutes']),
    );
  }

  static String? _firstText(Map<String, String> query, List<String> keys) {
    for (final key in keys) {
      final value = query[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static int? _firstInt(Map<String, String> query, List<String> keys) {
    final value = _firstText(query, keys);
    if (value == null) return null;
    final integer = int.tryParse(value);
    if (integer != null) return integer;

    final decimal = double.tryParse(value.replaceAll(',', '.'));
    return decimal != null && decimal == decimal.roundToDouble()
        ? decimal.toInt()
        : null;
  }

  static double? _firstDouble(Map<String, String> query, List<String> keys) {
    final value = _firstText(query, keys);
    return value == null ? null : double.tryParse(value.replaceAll(',', '.'));
  }
}
