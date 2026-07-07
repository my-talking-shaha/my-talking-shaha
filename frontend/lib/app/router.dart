import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/core/ui/navigation_shell.dart';
import 'package:frontend/core/utils/uuid_format.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/registration_screen.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:frontend/features/parts/presentation/providers/parts_providers.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/garage',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;
      final isAuthRoute =
          path == '/login' || path == '/registration' || path == '/auth';
      final isRestoringSession = authState.isLoading && !authState.hasValue;

      if (isRestoringSession) {
        return isAuthRoute ? null : '/auth';
      }

      final session = authState.maybeWhen(
        data: (session) => session,
        orElse: () => null,
      );
      final isAuthenticated = session != null;
      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      final invalidVehicleRedirect = _invalidVehicleRedirect(state.uri);
      if (invalidVehicleRedirect != null) {
        return invalidVehicleRedirect;
      }

      return isAuthRoute ? '/garage' : null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const _AuthLoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/registration',
        builder: (context, state) => const RegistrationScreen(),
      ),
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
          final query = state.uri.queryParameters;
          final initialType = _historyEventTypeFromQuery(query['type']);
          final prefillMileageKm = int.tryParse(query['mileageKm'] ?? '');
          return Consumer(
            builder: (context, ref, _) {
              final mileageState = ref.watch(vehicleMileageProvider(vehicleId));

              return mileageState.when(
                data: (currentMileageKm) {
                  final initialMileageKm = prefillMileageKm == null
                      ? currentMileageKm
                      : prefillMileageKm < currentMileageKm
                      ? currentMileageKm
                      : prefillMileageKm;
                  return AddHistoryEventScreen(
                    vehicleId: vehicleId,
                    initialMileageKm: initialMileageKm,
                    initialType: initialType,
                    onSave: (event) => _saveHistoryEvent(ref, event),
                    persistPhoto: ref
                        .read(historyPhotoStorageProvider)
                        .persistPhoto,
                    deletePhoto: ref
                        .read(historyPhotoStorageProvider)
                        .deletePhoto,
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
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/history/:eventId/edit',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          final eventId = state.pathParameters['eventId'] ?? '';
          final initialEvent = state.extra is HistoryEvent
              ? state.extra as HistoryEvent
              : null;

          return Consumer(
            builder: (context, ref, _) {
              Widget screenFor(HistoryEvent event) {
                return AddHistoryEventScreen(
                  vehicleId: vehicleId,
                  initialEvent: event,
                  initialMileageKm: event.currentMileageKm,
                  initialType: event.type,
                  onSave: ref.read(updateHistoryEventProvider),
                  persistPhoto: ref
                      .read(historyPhotoStorageProvider)
                      .persistPhoto,
                  deletePhoto: ref
                      .read(historyPhotoStorageProvider)
                      .deletePhoto,
                );
              }

              if (initialEvent != null) {
                return screenFor(initialEvent);
              }

              final eventsState = ref.watch(historyEventsProvider(vehicleId));
              return eventsState.when(
                data: (events) {
                  final event = _historyEventById(events, eventId);
                  if (event == null) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: const Center(child: Text('Event not found')),
                    );
                  }

                  return screenFor(event);
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
                pageBuilder: (context, state) =>
                    _tabPage(state: state, child: const GarageScreen()),
              ),
              GoRoute(
                path: '/vehicle/:vehicleId/dashboard',
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  return _tabPage(
                    state: state,
                    child: DashboardScreen(
                      vehicleId: vehicleId,
                      launchedFromChat: _launchedFromChat(state.uri),
                    ),
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
                    child: HistoryScreen(
                      vehicleId: vehicleId,
                      launchedFromChat: _launchedFromChat(state.uri),
                    ),
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
                    child: ChatScreen(vehicleId: vehicleId),
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
                    child: AnalyticsScreen(
                      vehicleId: vehicleId,
                      launchedFromChat: _launchedFromChat(state.uri),
                    ),
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

final _routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final class _AuthLoadingScreen extends ConsumerWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      _leaveAuthLoadingScreen(context, next);
    });
    _leaveAuthLoadingScreen(context, authState);

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

void _leaveAuthLoadingScreen(
  BuildContext context,
  AsyncValue<AuthSession?> authState,
) {
  if (authState.isLoading && !authState.hasValue) {
    return;
  }

  final session = authState.maybeWhen(
    data: (session) => session,
    orElse: () => null,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }

    context.go(session == null ? '/login' : '/garage');
  });
}

NoTransitionPage<void> _tabPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

String? _invalidVehicleRedirect(Uri uri) {
  if (uri.pathSegments case [
    'vehicle',
    final vehicleId,
    ...,
  ] when !isUuid(vehicleId)) {
    return '/garage';
  }

  if (uri.pathSegments case [
    'garage',
    'edit',
    final vehicleId,
  ] when !isUuid(vehicleId)) {
    return '/garage';
  }

  final queryVehicleId = uri.queryParameters['vehicleId'];
  if (queryVehicleId != null && !isUuid(queryVehicleId)) {
    return Uri(path: uri.path).toString();
  }

  return null;
}

HistoryEventType _historyEventTypeFromQuery(String? value) {
  return switch (value?.toLowerCase()) {
    'trip' => HistoryEventType.trip,
    'maintenance' || 'part_replacement' => HistoryEventType.maintenance,
    _ => HistoryEventType.fuel,
  };
}

HistoryEvent? _historyEventById(List<HistoryEvent> events, String eventId) {
  for (final event in events) {
    if (event.id == eventId) {
      return event;
    }
  }

  return null;
}

bool _launchedFromChat(Uri uri) {
  return uri.queryParameters['from'] == 'chat';
}

Future<void> _saveHistoryEvent(WidgetRef ref, HistoryEvent event) async {
  await ref.read(addHistoryEventProvider)(event);
  final vehicleId = event.carId;
  ref.invalidate(historyEventsProvider(vehicleId));
  ref.invalidate(garageControllerProvider);
  ref.invalidate(vehicleMileageProvider(vehicleId));
  ref.invalidate(vehicleDashboardProvider(vehicleId));
  ref.invalidate(vehiclePartsProvider(vehicleId));
  ref.invalidate(analyticsSummaryProvider);
}
