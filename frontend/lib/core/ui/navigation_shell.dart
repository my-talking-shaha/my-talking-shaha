import 'package:flutter/material.dart';
import 'package:frontend/core/ui/bottom_nav_bar.dart';
import 'package:frontend/core/utils/uuid_format.dart';
import 'package:go_router/go_router.dart';

final class NavigationShell extends StatelessWidget {
  const NavigationShell({
    required this.uri,
    required this.navigationShell,
    super.key,
  });

  final Uri uri;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final vehicleId = _vehicleId;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: PrimaryBottomNavBar(
        selectedDestination: Destination.values[navigationShell.currentIndex],
        hasVehicleContext: vehicleId != null,
        onDestinationSelected: (destination) {
          final location = _locationFor(destination, vehicleId);
          if (location != null && location != uri.toString()) {
            context.go(location);
          }
        },
      ),
    );
  }

  String? get _vehicleId {
    if (uri.pathSegments case ['vehicle', final vehicleId, ...]) {
      return isUuid(vehicleId) ? vehicleId : null;
    }

    final vehicleId = uri.queryParameters['vehicleId'];
    return vehicleId != null && isUuid(vehicleId) ? vehicleId : null;
  }

  String? _locationFor(Destination destination, String? vehicleId) {
    return switch (destination) {
      Destination.garage when vehicleId != null =>
        '/vehicle/$vehicleId/dashboard',
      Destination.garage => '/garage',
      Destination.history when vehicleId != null =>
        '/vehicle/$vehicleId/history',
      Destination.chat when vehicleId != null => '/vehicle/$vehicleId/chat',
      Destination.analytics when vehicleId != null =>
        '/vehicle/$vehicleId/analytics',
      Destination.settings when vehicleId != null => Uri(
        path: '/settings',
        queryParameters: {'vehicleId': vehicleId},
      ).toString(),
      Destination.settings => '/settings',
      _ => null,
    };
  }
}
