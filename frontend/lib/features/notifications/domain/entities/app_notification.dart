enum AppNotificationType { partLifetimeWarning, maintenanceReminder, system }

final class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    required this.read,
    this.vehicleId,
    this.partId,
    this.remainingKm,
    this.recommendedAction,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final AppNotificationType type;
  final bool read;
  final String? vehicleId;
  final String? partId;
  final int? remainingKm;
  final String? recommendedAction;
}
