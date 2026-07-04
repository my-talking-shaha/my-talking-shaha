final class MileageTrendFilter {
  const MileageTrendFilter({required this.year, this.month});

  final int year;
  final int? month;

  @override
  bool operator ==(Object other) {
    return other is MileageTrendFilter &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);
}

final class MileageTrendPoint {
  const MileageTrendPoint({required this.label, required this.mileageKm});

  final String label;
  final int mileageKm;
}

final class MileageTrend {
  const MileageTrend({
    required this.year,
    required this.month,
    required this.points,
    required this.hasData,
  });

  final int year;
  final int? month;
  final List<MileageTrendPoint> points;
  final bool hasData;
}
