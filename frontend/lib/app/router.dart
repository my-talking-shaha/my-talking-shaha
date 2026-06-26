import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/core/ui/navigation_shell.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/chat/presentation/screens/chat_placeholder_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_screen.dart';
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
              final mileageState = ref.watch(vehicleMileageProvider(vehicleId));

              return mileageState.when(
                data: (currentMileageKm) {
                  return AddHistoryEventScreen(
                    vehicleId: vehicleId,
                    initialMileageKm: currentMileageKm,
                    onSave: ref.read(addHistoryEventProvider),
                    persistPhoto:
                        ref.read(historyPhotoStorageProvider).persistPhoto,
                    deletePhoto:
                        ref.read(historyPhotoStorageProvider).deletePhoto,
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
                        ref.invalidate(vehicleMileageProvider(vehicleId));
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
                pageBuilder: (context, state) =>
                    _tabPage(state: state, child: const GarageScreen()),
              ),
              GoRoute(
                path: '/vehicle/:vehicleId/dashboard',
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: DashboardScreen(vehicleId: vehicleId),
                  );
                },
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
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: HistoryScreen(vehicleId: vehicleId),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/chat', redirect: (context, state) => '/garage'),
              GoRoute(
                path: '/vehicle/:vehicleId/chat',
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: ChatPlaceholderScreen(vehicleId: vehicleId),
                  );
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
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: AnalyticsScreen(vehicleId: vehicleId),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    _tabPage(state: state, child: const SettingsScreen()),
              ),
              GoRoute(
                path: '/notifications',
                pageBuilder: (context, state) =>
                    _tabPage(state: state, child: const NotificationsScreen()),
              ),
              GoRoute(
                path: '/notifications/:notificationId',
                pageBuilder: (context, state) {
                  final notificationId =
                      state.pathParameters['notificationId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: NotificationDetailsScreen(
                      notificationId: notificationId,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

NoTransitionPage<void> _tabPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
