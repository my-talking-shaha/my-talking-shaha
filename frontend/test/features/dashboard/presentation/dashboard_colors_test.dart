import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_event_presentation.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  test('dashboard palette preserves the visual baseline', () {
    expect(DashboardColors.background.toARGB32(), 0xFF10131A);
    expect(DashboardColors.primary.toARGB32(), 0xFF2E5BFF);
    expect(DashboardColors.primaryLight.toARGB32(), 0xFFB8C3FF);
    expect(DashboardColors.surface.toARGB32(), 0xFF1C1F25);
    expect(DashboardColors.surfaceHighest.toARGB32(), 0xFF232731);
    expect(DashboardColors.border.toARGB32(), 0xFF2B303B);
    expect(DashboardColors.textPrimary.toARGB32(), 0xFFF4F7FF);
    expect(DashboardColors.textSecondary.toARGB32(), 0xFF9AA3B2);
    expect(DashboardColors.textMuted.toARGB32(), 0xFF6F7788);
    expect(DashboardColors.textDisabled.toARGB32(), 0xFF4B5263);
    expect(DashboardColors.success.toARGB32(), 0xFF00DCE5);
    expect(DashboardColors.warning.toARGB32(), 0xFFE8B950);
    expect(DashboardColors.transparent.toARGB32(), 0x00000000);
    expect(DashboardColors.heroOverlay.toARGB32(), 0xE610131A);
    expect(DashboardColors.heroGradientStart.toARGB32(), 0xFF102B3B);
    expect(DashboardColors.heroGradientMiddle.toARGB32(), 0xFF131B31);
    expect(DashboardColors.heroGradientEnd.toARGB32(), 0xFF10131A);
    expect(DashboardColors.fuelEventBackground.toARGB32(), 0xFF30291F);
    expect(DashboardColors.maintenanceEventBackground.toARGB32(), 0xFF123138);
  });

  test('event types preserve their visual presentation', () {
    final fuel = DashboardEventPresentation.from(HistoryEventType.fuel);
    final maintenance = DashboardEventPresentation.from(
      HistoryEventType.maintenance,
    );
    final trip = DashboardEventPresentation.from(HistoryEventType.trip);

    expect(fuel.assetPath, 'assets/icons/events/gas.svg');
    expect(fuel.iconColor, DashboardColors.warning);
    expect(fuel.backgroundColor, DashboardColors.fuelEventBackground);
    expect(maintenance.assetPath, 'assets/icons/events/spanner.svg');
    expect(maintenance.iconColor, DashboardColors.success);
    expect(
      maintenance.backgroundColor,
      DashboardColors.maintenanceEventBackground,
    );
    expect(trip.assetPath, 'assets/icons/events/trip.svg');
    expect(trip.iconColor, DashboardColors.primaryLight);
    expect(trip.backgroundColor, DashboardColors.surfaceHighest);
  });
}
