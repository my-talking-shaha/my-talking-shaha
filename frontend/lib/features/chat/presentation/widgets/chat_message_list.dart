import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_assistant_mark.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    required this.vehicleId,
    required this.messages,
    required this.scrollController,
    required this.isSending,
    super.key,
  });

  final String vehicleId;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const _TypingBubble();
        }

        return _ChatBubble(vehicleId: vehicleId, message: messages[index]);
      },
    );
  }
}

final class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.vehicleId, required this.message});

  final String vehicleId;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFactor = isUser ? 0.76 : 0.82;
        final maxBubbleWidth = (constraints.maxWidth * widthFactor).clamp(
          0.0,
          620.0,
        );
        final bubble = Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: IntrinsicWidth(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.lg),
                    topRight: const Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(
                      isUser ? AppRadius.lg : AppSpacing.xs,
                    ),
                    bottomRight: Radius.circular(
                      isUser ? AppSpacing.xs : AppRadius.lg,
                    ),
                  ),
                  border: Border.all(
                    color: isUser ? AppColors.primaryPressed : AppColors.border,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isUser ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.lg,
                    isUser ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      if (!isUser && message.action != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ChatActionPill(
                          vehicleId: vehicleId,
                          action: message.action!,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatTime(message.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isUser
                                    ? AppColors.white.withValues(alpha: 0.7)
                                    : AppColors.textMuted,
                                height: 1,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const ChatAssistantMark(size: 32, iconSize: 16),
                const SizedBox(width: AppSpacing.sm),
              ],
              bubble,
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

final class _ChatActionPill extends StatelessWidget {
  const _ChatActionPill({required this.vehicleId, required this.action});

  final String vehicleId;
  final ChatAction action;

  @override
  Widget build(BuildContext context) {
    final destination = _destination();
    if (destination == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('chat_message_action'),
          onTap: () {
            if (_opensShellScreen) {
              context.go(destination);
            } else {
              unawaited(context.push(destination));
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(), size: 16, color: AppColors.primaryLight),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _label(context),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _destination() {
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      final path = switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => '/vehicle/$vehicleId/analytics',
        'HISTORY' || 'TIMELINE' => '/vehicle/$vehicleId/history',
        'DASHBOARD' ||
        'MAINTENANCE_FORECAST' => '/vehicle/$vehicleId/dashboard',
        _ => null,
      };
      if (path == null) return null;

      return Uri(
        path: path,
        queryParameters: const {'from': 'chat'},
      ).toString();
    }

    if (type == 'OPEN_FORM') {
      final form = action.form?.toUpperCase();
      final routeType = switch (form) {
        'TRIP' => 'trip',
        'MAINTENANCE' || 'PART_REPLACEMENT' => 'maintenance',
        _ => 'fuel',
      };
      final query = <String, String>{'type': routeType};
      final mileageKm = action.prefill['mileageKm']?.toString();
      if (mileageKm != null && mileageKm.isNotEmpty) {
        query['mileageKm'] = mileageKm;
      }

      return Uri(
        path: '/vehicle/$vehicleId/history/add',
        queryParameters: query,
      ).toString();
    }

    return null;
  }

  bool get _opensShellScreen => action.type.toUpperCase() == 'OPEN_SCREEN';

  String _label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      return switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => l10n.openAnalytics,
        'HISTORY' || 'TIMELINE' => l10n.maintenanceHistory,
        'MAINTENANCE_FORECAST' => l10n.openForecast,
        'DASHBOARD' => l10n.openDashboard,
        _ => l10n.open,
      };
    }

    return switch (action.form?.toUpperCase()) {
      'REFUEL' => l10n.addRefuel,
      'TRIP' => l10n.addTrip,
      'PART_REPLACEMENT' => l10n.addPartRecord,
      'MAINTENANCE' => l10n.addMaintenance,
      _ => l10n.openForm,
    };
  }

  IconData _icon() {
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      return switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => Icons.bar_chart_rounded,
        'HISTORY' || 'TIMELINE' => Icons.history_rounded,
        'MAINTENANCE_FORECAST' => Icons.build_circle_outlined,
        'DASHBOARD' => Icons.directions_car_filled_rounded,
        _ => Icons.open_in_new_rounded,
      };
    }

    return switch (action.form?.toUpperCase()) {
      'REFUEL' => Icons.local_gas_station_rounded,
      'TRIP' => Icons.route_rounded,
      'PART_REPLACEMENT' => Icons.build_circle_outlined,
      'MAINTENANCE' => Icons.handyman_rounded,
      _ => Icons.open_in_new_rounded,
    };
  }
}

final class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

final class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ChatAssistantMark(size: 32, iconSize: 16),
          const SizedBox(width: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Semantics(
                label: 'Assistant is thinking',
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ThinkingWaveText(progress: _controller.value),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ThinkingWaveText extends StatelessWidget {
  const _ThinkingWaveText({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final waveStart = -1.4 + progress * 2.8;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(waveStart, 0),
          end: Alignment(waveStart + 1.1, 0),
          colors: const [
            AppColors.textSecondary,
            AppColors.primaryLight,
            AppColors.textPrimary,
            AppColors.primaryLight,
            AppColors.textSecondary,
          ],
          stops: const [0, 0.28, 0.5, 0.72, 1],
        ).createShader(bounds);
      },
      child: Text(
        'Shaha is thinking',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}
