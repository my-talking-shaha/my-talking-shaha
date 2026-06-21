import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';

enum Destination { garage, history, chat, analytics, settings }

final class PrimaryBottomNavBar extends StatelessWidget {
  const PrimaryBottomNavBar({
    required this.selectedDestination,
    required this.hasVehicleContext,
    required this.onDestinationSelected,
    super.key,
  });

  final Destination selectedDestination;
  final bool hasVehicleContext;
  final ValueChanged<Destination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = Destination.values
        .where(
          (destination) => hasVehicleContext || !destination.requiresVehicle,
        )
        .toList();
    final selectedIndex = destinations.indexOf(selectedDestination);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onTap: (index) {
        onDestinationSelected(destinations[index]);
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: destinations.map((destination) {
        final label = destination.label(hasVehicleContext: hasVehicleContext);
        return BottomNavigationBarItem(
          icon: _NavigationIcon(
            destination: destination,
            color: AppColors.textMuted,
          ),
          activeIcon: _NavigationIcon(
            destination: destination,
            color: AppColors.primaryLight,
          ),
          label: label,
          tooltip: label,
        );
      }).toList(),
    );
  }
}

final class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.destination, required this.color});

  final Destination destination;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      destination.assetPath,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

extension on Destination {
  String label({required bool hasVehicleContext}) => switch (this) {
    Destination.garage => hasVehicleContext ? 'Dashboard' : 'Garage',
    Destination.history => 'History',
    Destination.chat => 'Chat',
    Destination.analytics => 'Analytics',
    Destination.settings => 'Settings',
  };

  String get assetPath => switch (this) {
    Destination.garage => 'assets/icons/navigation/car.svg',
    Destination.history => 'assets/icons/navigation/history.svg',
    Destination.chat => 'assets/icons/navigation/chat.svg',
    Destination.analytics => 'assets/icons/navigation/stats.svg',
    Destination.settings => 'assets/icons/navigation/settings.svg',
  };

  bool get requiresVehicle => switch (this) {
    Destination.history || Destination.chat || Destination.analytics => true,
    Destination.garage || Destination.settings => false,
  };
}
