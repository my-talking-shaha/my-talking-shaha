import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/presentation/screens/chat_placeholder_screen.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/garage',
    routes: [
      GoRoute(
        path: '/garage',
        builder: (context, state) => const GarageScreen(),
      ),
      GoRoute(
        path: '/garage/add',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/chat',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return ChatPlaceholderScreen(vehicleId: vehicleId);
        },
      ),
    ],
  );
});
