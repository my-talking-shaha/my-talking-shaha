import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:go_router/go_router.dart';

VoidCallback partsBackAction(BuildContext context) {
  return () => context.go('/garage');
}

VoidCallback partsRetryAction(WidgetRef ref, String vehicleId) {
  return () => ref.invalidate(vehiclePartsProvider(vehicleId));
}
