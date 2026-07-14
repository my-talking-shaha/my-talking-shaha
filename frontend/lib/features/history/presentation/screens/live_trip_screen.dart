import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/di/live_trip_providers.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/use_cases/create_live_trip_event.dart';
import 'package:frontend/features/history/presentation/utils/history_event_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class LiveTripScreen extends ConsumerStatefulWidget {
  const LiveTripScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<LiveTripScreen> createState() => _LiveTripScreenState();
}

final class _LiveTripScreenState extends ConsumerState<LiveTripScreen> {
  Timer? _ticker;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tripState = ref.watch(liveTripControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveTrip)),
      body: SafeArea(
        top: false,
        child: tripState.when(
          data: (session) {
            if (session == null || session.vehicleId != widget.vehicleId) {
              return _NoActiveTrip(vehicleId: widget.vehicleId);
            }
            return _LiveTripContent(
              session: session,
              now: DateTime.now(),
              isFinishing: _isFinishing,
              onFinish: () => _finish(session),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _NoActiveTrip(vehicleId: widget.vehicleId),
        ),
      ),
    );
  }

  Future<void> _finish(LiveTripSession session) async {
    final result = await showModalBottomSheet<LiveTripFinishResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => LiveTripFinishSheet(session: session),
    );
    if (result == null || !mounted) return;

    setState(() => _isFinishing = true);
    final l10n = AppLocalizations.of(context);
    try {
      final event = ref.read(createLiveTripEventProvider)(
        session: session,
        endMileageKm: result.endMileageKm,
        endedAt: DateTime.now(),
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        title: l10n.tripEvent,
        route: result.route,
      );
      await ref.read(addHistoryEventProvider)(event);
      try {
        await ref.read(liveTripControllerProvider.notifier).end();
      } catch (_) {
        // The trip is already stored remotely; do not invite a duplicate save.
      }
      if (mounted) context.pop(event);
    } on LiveTripMileageException {
      _showError(l10n.mileageAtLeastKm(session.startMileageKm));
    } catch (_) {
      _showError(l10n.couldNotFinishTrip);
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _LiveTripContent extends StatelessWidget {
  const _LiveTripContent({
    required this.session,
    required this.now,
    required this.isFinishing,
    required this.onFinish,
  });

  final LiveTripSession session;
  final DateTime now;
  final bool isFinishing;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final elapsed = session.elapsedAt(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primarySoft,
              border: Border.all(color: colors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.24),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 48,
              color: colors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.tripInProgress,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _formatDuration(elapsed),
          key: const ValueKey('live-trip-elapsed'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: colors.primaryLight,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _TripMetricRow(
                  icon: Icons.schedule_rounded,
                  label: l10n.startedAtLabel,
                  value: HistoryEventFormUtils.formatDateTime(
                    session.startedAt,
                  ),
                ),
                Divider(
                  height: AppSpacing.xl,
                  thickness: 1,
                  indent: 24 + AppSpacing.md,
                  color: colors.border.withValues(alpha: 0.72),
                ),
                _TripMetricRow(
                  icon: Icons.speed_rounded,
                  label: l10n.startMileageLabel,
                  value: '${session.startMileageKm} km',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.liveTripHint,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ElevatedButton(
          key: const ValueKey('finish-live-trip'),
          onPressed: isFinishing ? null : onFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
          ),
          child: isFinishing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.finishTrip),
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

final class _TripMetricRow extends StatelessWidget {
  const _TripMetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, color: colors.info),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

final class _NoActiveTrip extends StatelessWidget {
  const _NoActiveTrip({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_outlined, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noActiveTrip),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.go('/vehicle/$vehicleId/history'),
              child: Text(l10n.backToHistory),
            ),
          ],
        ),
      ),
    );
  }
}

final class LiveTripFinishResult {
  const LiveTripFinishResult({required this.endMileageKm, required this.route});

  final int endMileageKm;
  final String? route;
}

final class LiveTripFinishSheet extends StatefulWidget {
  const LiveTripFinishSheet({required this.session, super.key});

  final LiveTripSession session;

  @override
  State<LiveTripFinishSheet> createState() => _LiveTripFinishSheetState();
}

final class _LiveTripFinishSheetState extends State<LiveTripFinishSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mileageController;
  final _routeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController(
      text: widget.session.startMileageKm.toString(),
    );
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.finishTrip,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.finishTripDescription),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: const ValueKey('live-trip-end-mileage'),
              controller: _mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.endMileageLabel,
                suffixText: 'km',
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
              validator: (value) {
                final mileage = int.tryParse(value ?? '');
                if (mileage == null ||
                    mileage < widget.session.startMileageKm) {
                  return l10n.mileageAtLeastKm(widget.session.startMileageKm);
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const ValueKey('live-trip-route'),
              controller: _routeController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.routeOptional,
                prefixIcon: const Icon(Icons.route_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              key: const ValueKey('save-live-trip'),
              onPressed: _submit,
              child: Text(l10n.finishAndSaveTrip),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final route = _routeController.text.trim();
    Navigator.of(context).pop(
      LiveTripFinishResult(
        endMileageKm: int.parse(_mileageController.text),
        route: route.isEmpty ? null : route,
      ),
    );
  }
}
