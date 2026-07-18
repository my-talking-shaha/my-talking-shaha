import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/history_mutation_invalidation_provider.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/core/ui/navigation_shell.dart';
import 'package:frontend/core/utils/uuid_format.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/registration_screen.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/history/presentation/screens/live_trip_screen.dart';
import 'package:frontend/features/history/presentation/state/history_event_form_prefill.dart';
import 'package:frontend/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_screen.dart';
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
          final initialPrefill = HistoryEventFormPrefill.fromQueryParameters(
            query,
          );
          final prefillMileageKm = initialPrefill.mileageKm;
          final launchedFromChat = _launchedFromChat(state.uri);
          final onClose = launchedFromChat
              ? () => context.go('/vehicle/$vehicleId/chat')
              : null;
          final content = Consumer(
            builder: (context, ref, _) {
              final mileageState = ref.watch(vehicleMileageProvider(vehicleId));
              final engineTypeState = ref.watch(
                vehicleEngineTypeProvider(vehicleId),
              );

              return mileageState.when(
                data: (currentMileageKm) {
                  return engineTypeState.when(
                    data: (engineType) {
                      final initialMileageKm = prefillMileageKm == null
                          ? currentMileageKm
                          : prefillMileageKm < currentMileageKm
                          ? currentMileageKm
                          : prefillMileageKm;
                      return AddHistoryEventScreen(
                        vehicleId: vehicleId,
                        initialMileageKm: initialMileageKm,
                        initialType: initialType,
                        initialPrefill: initialPrefill,
                        isElectricVehicle: _isElectricEngine(engineType),
                        onClose: onClose,
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
                      body: Center(child: NativeActivityIndicator()),
                    ),
                    error: (error, stackTrace) => Scaffold(
                      appBar: AppBar(),
                      body: Center(
                        child: TextButton(
                          onPressed: () {
                            ref.invalidate(
                              vehicleEngineTypeProvider(vehicleId),
                            );
                          },
                          child: Text(AppLocalizations.of(context).retry),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Scaffold(
                  body: Center(child: NativeActivityIndicator()),
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
          return onClose == null
              ? content
              : _RoutePopScope(onPop: onClose, child: content);
        },
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/history/live',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return LiveTripScreen(vehicleId: vehicleId);
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
          final launchedFromChat = _launchedFromChat(state.uri);
          final onClose = launchedFromChat
              ? () => context.go('/vehicle/$vehicleId/chat')
              : null;

          final content = Consumer(
            builder: (context, ref, _) {
              Widget screenFor(HistoryEvent event) {
                return AddHistoryEventScreen(
                  vehicleId: vehicleId,
                  initialEvent: event,
                  initialMileageKm: event.currentMileageKm,
                  initialType: event.type,
                  isElectricVehicle: _isRechargeEvent(event),
                  onClose: onClose,
                  onSave: (event) => _updateHistoryEvent(ref, event),
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
                    return _MissingHistoryEvent(
                      onClose:
                          onClose ??
                          () => context.go('/vehicle/$vehicleId/history'),
                    );
                  }

                  return screenFor(event);
                },
                loading: () => const Scaffold(
                  body: Center(child: NativeActivityIndicator()),
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
          return onClose == null
              ? content
              : _RoutePopScope(onPop: onClose, child: content);
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

    return const Scaffold(body: Center(child: NativeActivityIndicator()));
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

final class _RoutePopScope extends StatelessWidget {
  const _RoutePopScope({required this.onPop, required this.child});

  final VoidCallback onPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onPop();
      },
      child: child,
    );
  }
}

final class _MissingHistoryEvent extends StatefulWidget {
  const _MissingHistoryEvent({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_MissingHistoryEvent> createState() => _MissingHistoryEventState();
}

final class _MissingHistoryEventState extends State<_MissingHistoryEvent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_showMessageAndClose());
    });
  }

  Future<void> _showMessageAndClose() async {
    showNativeMessage(context, AppLocalizations.of(context).eventNotFound);
    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation != null &&
        routeAnimation.status != AnimationStatus.completed) {
      final completed = Completer<void>();
      late AnimationStatusListener listener;
      listener = (status) {
        if (status != AnimationStatus.completed) return;
        routeAnimation.removeStatusListener(listener);
        completed.complete();
      };
      routeAnimation.addStatusListener(listener);
      await completed.future;
    }
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
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
    'part' || 'part_replacement' => HistoryEventType.part,
    'maintenance' => HistoryEventType.maintenance,
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

bool _isElectricEngine(String? engineType) {
  return engineType?.toLowerCase() == 'electric';
}

bool _isRechargeEvent(HistoryEvent event) {
  return switch (event.details) {
    FuelDetails(:final isRecharge) => isRecharge,
    _ => false,
  };
}

Future<void> _saveHistoryEvent(WidgetRef ref, HistoryEvent event) async {
  final save = ref.read(addHistoryEventProvider);
  final invalidate = ref.read(historyMutationInvalidationProvider);
  await save(event);
  invalidate(event.carId);
}

Future<void> _updateHistoryEvent(WidgetRef ref, HistoryEvent event) async {
  final update = ref.read(updateHistoryEventProvider);
  final invalidate = ref.read(historyMutationInvalidationProvider);
  await update(event);
  invalidate(event.carId);
}
