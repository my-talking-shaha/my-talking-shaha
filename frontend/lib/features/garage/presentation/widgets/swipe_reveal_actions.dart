import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class SwipeRevealAction {
  const SwipeRevealAction({
    required this.label,
    required this.iconPath,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String iconPath;
  final Color color;
  final VoidCallback onPressed;
}

final class SwipeRevealActions extends StatefulWidget {
  const SwipeRevealActions({
    required this.child,
    required this.actions,
    super.key,
  });

  final Widget child;
  final List<SwipeRevealAction> actions;

  @override
  State<SwipeRevealActions> createState() => _SwipeRevealActionsState();
}

final class _SwipeRevealActionsState extends State<SwipeRevealActions> {
  static const double _actionWidth = 120;
  double _dragOffset = 0;

  bool get _isOpen => _dragOffset < 0;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dx).clamp(
            -_actionWidth,
            0,
          );
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _dragOffset = _dragOffset.abs() > _actionWidth * 0.38
              ? -_actionWidth
              : 0;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.actions
                      .map((action) => _SwipeActionButton(action: action))
                      .toList(growable: false),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            key: const ValueKey('garage_swipe_foreground'),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: GestureDetector(
              onTap: _isOpen
                  ? () {
                      setState(() {
                        _dragOffset = 0;
                      });
                    }
                  : null,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

final class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({required this.action});

  final SwipeRevealAction action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: action.label,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: IconButton.filled(
                key: ValueKey(
                  'garage_swipe_action_${action.label.toLowerCase()}',
                ),
                onPressed: action.onPressed,
                style: IconButton.styleFrom(
                  backgroundColor: action.color,
                  foregroundColor: context.appColors.white,
                  shape: const CircleBorder(),
                ),
                icon: SvgPicture.asset(
                  action.iconPath,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    context.appColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
