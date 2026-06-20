import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/ui/navigation_shell.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/chat/presentation/screens/chat_placeholder_screen.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/garage',
    routes: [
      GoRoute(
        path: '/garage/add',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/garage/edit/:vehicleId',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return AddVehicleScreen(vehicleId: vehicleId);
        },
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/history/add',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return Consumer(
            builder: (context, ref, _) {
              final eventsState = ref.watch(historyEventsProvider(vehicleId));

              return eventsState.when(
                data: (events) {
                  final currentMileageKm = events.fold<int>(
                    0,
                    (maximum, event) => event.currentMileageKm > maximum
                        ? event.currentMileageKm
                        : maximum,
                  );

                  return AddHistoryEventScreen(
                    vehicleId: vehicleId,
                    initialMileageKm: currentMileageKm,
                    onSave: ref.read(addHistoryEventProvider),
                  );
                },
                loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: TextButton(
                      onPressed: () {
                        ref.invalidate(historyEventsProvider(vehicleId));
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(
            uri: state.uri,
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garage',
                builder: (context, state) => const GarageScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                redirect: (context, state) => '/garage',
              ),
              GoRoute(
                path: '/vehicle/:vehicleId/history',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return HistoryScreen(vehicleId: vehicleId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/chat', redirect: (context, state) => '/garage'),
              GoRoute(
                path: '/vehicle/:vehicleId/chat',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return ChatPlaceholderScreen(vehicleId: vehicleId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                redirect: (context, state) => '/garage',
              ),
              GoRoute(
                path: '/vehicle/:vehicleId/analytics',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return AnalyticsScreen(vehicleId: vehicleId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
