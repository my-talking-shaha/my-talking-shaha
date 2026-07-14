import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui_platform.dart';

@immutable
final class NativePickerItem<T> {
  const NativePickerItem({required this.value, required this.label});

  final T value;
  final String label;
}

Future<T?> _showCupertinoPicker<T>({
  required BuildContext anchorContext,
  required List<NativePickerItem<T>> items,
  T? selectedValue,
  String? title,
}) {
  final navigator = Navigator.of(anchorContext, rootNavigator: true);
  final anchorBox = anchorContext.findRenderObject()! as RenderBox;
  final overlayBox =
      navigator.overlay!.context.findRenderObject()! as RenderBox;
  final anchorOffset = anchorBox.localToGlobal(
    Offset.zero,
    ancestor: overlayBox,
  );

  return navigator.push<T>(
    _CupertinoDropdownRoute<T>(
      anchorRect: anchorOffset & anchorBox.size,
      items: items,
      selectedValue: selectedValue,
      semanticLabel: title,
      barrierLabel: CupertinoLocalizations.of(
        anchorContext,
      ).modalBarrierDismissLabel,
    ),
  );
}

final class _CupertinoDropdownRoute<T> extends PopupRoute<T> {
  _CupertinoDropdownRoute({
    required this.anchorRect,
    required this.items,
    required this.selectedValue,
    required this.semanticLabel,
    required this.barrierLabel,
  });

  final Rect anchorRect;
  final List<NativePickerItem<T>> items;
  final T? selectedValue;
  final String? semanticLabel;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 120);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _CupertinoDropdownMenu<T>(
      anchorRect: anchorRect,
      items: items,
      selectedValue: selectedValue,
      semanticLabel: semanticLabel,
      animation: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }
}

final class _CupertinoDropdownMenu<T> extends StatelessWidget {
  const _CupertinoDropdownMenu({
    required this.anchorRect,
    required this.items,
    required this.selectedValue,
    required this.semanticLabel,
    required this.animation,
  });

  static const _horizontalMargin = 8.0;
  static const _anchorGap = 6.0;
  static const _rowHeight = 52.0;
  static const _separatorHeight = 1.0;
  static const _minimumWidth = 200.0;
  static const _maximumWidth = 380.0;
  static const _maximumHeight = 416.0;

  final Rect anchorRect;
  final List<NativePickerItem<T>> items;
  final T? selectedValue;
  final String? semanticLabel;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final safeTop = mediaQuery.padding.top + _horizontalMargin;
    final safeBottom =
        screenSize.height -
        math.max(mediaQuery.padding.bottom, mediaQuery.viewInsets.bottom) -
        _horizontalMargin;
    final desiredHeight = math.min(
      items.length * _rowHeight +
          math.max(0, items.length - 1) * _separatorHeight,
      _maximumHeight,
    );
    final spaceBelow = math.max(
      0.0,
      safeBottom - anchorRect.bottom - _anchorGap,
    );
    final spaceAbove = math.max(0.0, anchorRect.top - safeTop - _anchorGap);
    final opensBelow =
        spaceBelow >= math.min(desiredHeight, _rowHeight * 3) ||
        spaceBelow >= spaceAbove;
    final availableHeight = opensBelow ? spaceBelow : spaceAbove;
    final menuHeight = math.min(
      desiredHeight,
      math.max(_rowHeight, availableHeight),
    );
    final availableWidth = screenSize.width - _horizontalMargin * 2;
    final menuWidth = math.min(
      availableWidth,
      math.max(_minimumWidth, math.min(anchorRect.width, _maximumWidth)),
    );
    final left = anchorRect.left.clamp(
      _horizontalMargin,
      screenSize.width - menuWidth - _horizontalMargin,
    );
    final top = opensBelow
        ? anchorRect.bottom + _anchorGap
        : anchorRect.top - menuHeight - _anchorGap;
    final alignment = opensBelow ? Alignment.topCenter : Alignment.bottomCenter;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: menuWidth,
          height: menuHeight,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
              alignment: alignment,
              child: Semantics(
                label: semanticLabel,
                container: true,
                explicitChildNodes: true,
                child: _CupertinoDropdownSurface<T>(
                  items: items,
                  selectedValue: selectedValue,
                  onSelected: null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _CupertinoDropdownSurface<T> extends StatelessWidget {
  const _CupertinoDropdownSurface({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<NativePickerItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface.withValues(alpha: 0.94);
    final separatorColor = theme.dividerColor;
    final textColor = theme.colorScheme.onSurface;
    final checkColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: separatorColor.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 0.5, color: separatorColor),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.value == selectedValue;
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final selectionCallback = onSelected;
                      if (selectionCallback != null) {
                        selectionCallback(item.value);
                      } else {
                        Navigator.of(context).pop(item.value);
                      }
                    },
                    child: SizedBox(
                      height: _CupertinoDropdownMenu._rowHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: isSelected
                                  ? Icon(
                                      CupertinoIcons.check_mark,
                                      size: 20,
                                      color: checkColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class NativeAutocompleteOptions<T> extends StatelessWidget {
  const NativeAutocompleteOptions({
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
    this.backgroundColor,
    this.textStyle,
    this.maxHeight = 220,
    this.maxWidth = 480,
    super.key,
  });

  final Iterable<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double maxHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final optionList = options.toList(growable: false);
    final width = math.min(maxWidth, MediaQuery.sizeOf(context).width - 40);
    final height = math.min(
      optionList.length * _CupertinoDropdownMenu._rowHeight +
          math.max(0, optionList.length - 1) *
              _CupertinoDropdownMenu._separatorHeight,
      maxHeight,
    );

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: usesCupertinoNativeUi(context)
            ? _CupertinoDropdownSurface<T>(
                items: [
                  for (final option in optionList)
                    NativePickerItem(
                      value: option,
                      label: labelBuilder(option),
                    ),
                ],
                selectedValue: null,
                onSelected: onSelected,
              )
            : Material(
                color: backgroundColor,
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: optionList.length,
                  itemBuilder: (context, index) {
                    final option = optionList[index];
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: SizedBox(
                        height: _CupertinoDropdownMenu._rowHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              labelBuilder(option),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

final class NativePopupMenuButton<T> extends StatelessWidget {
  const NativePopupMenuButton({
    required this.items,
    required this.child,
    required this.onSelected,
    this.selectedValue,
    this.title,
    this.enabled = true,
    this.color,
    this.elevation,
    this.constraints,
    this.shape,
    this.textStyle,
    this.onOpened,
    super.key,
  });

  final List<NativePickerItem<T>> items;
  final Widget child;
  final ValueChanged<T> onSelected;
  final T? selectedValue;
  final String? title;
  final bool enabled;
  final Color? color;
  final double? elevation;
  final BoxConstraints? constraints;
  final ShapeBorder? shape;
  final TextStyle? textStyle;
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    if (!usesCupertinoNativeUi(context)) {
      return PopupMenuButton<T>(
        initialValue: selectedValue,
        enabled: enabled,
        color: color,
        elevation: elevation,
        constraints: constraints,
        shape: shape,
        onOpened: onOpened,
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<T>(
              value: item.value,
              child: Text(item.label, style: textStyle),
            ),
        ],
        child: child,
      );
    }

    return Builder(
      builder: (anchorContext) => Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () async {
                  onOpened?.call();
                  await Future<void>.delayed(Duration.zero);
                  if (!anchorContext.mounted) return;
                  final value = await _showCupertinoPicker<T>(
                    anchorContext: anchorContext,
                    items: items,
                    selectedValue: selectedValue,
                    title: title,
                  );
                  if (value != null && anchorContext.mounted) {
                    onSelected(value);
                  }
                }
              : null,
          child: child,
        ),
      ),
    );
  }
}

final class NativeDropdownFormField<T> extends StatelessWidget {
  const NativeDropdownFormField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.decoration,
    this.title,
    this.style,
    this.iconColor,
    this.dropdownColor,
    super.key,
  });

  final T value;
  final List<NativePickerItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final String? title;
  final TextStyle? style;
  final Color? iconColor;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    if (!usesCupertinoNativeUi(context)) {
      return DropdownButtonFormField<T>(
        initialValue: value,
        items: [
          for (final item in items)
            DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
        ],
        onChanged: onChanged,
        dropdownColor:
            dropdownColor ?? Theme.of(context).inputDecorationTheme.fillColor,
        decoration: decoration,
        style: style,
        iconEnabledColor: iconColor,
      );
    }

    final selectedLabel = items
        .where((item) => item.value == value)
        .map((item) => item.label)
        .firstOrNull;

    return Builder(
      builder: (anchorContext) => Semantics(
        button: true,
        enabled: onChanged != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null
              ? null
              : () async {
                  FocusScope.of(anchorContext).unfocus();
                  await Future<void>.delayed(Duration.zero);
                  if (!anchorContext.mounted) return;
                  final selected = await _showCupertinoPicker<T>(
                    anchorContext: anchorContext,
                    items: items,
                    selectedValue: value,
                    title: title,
                  );
                  if (selected != null && anchorContext.mounted) {
                    onChanged?.call(selected);
                  }
                },
          child: InputDecorator(
            decoration: decoration,
            isEmpty: selectedLabel == null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: onChanged == null
                      ? Theme.of(anchorContext).disabledColor
                      : iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
