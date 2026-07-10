import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class ChatSuggestionStrip extends StatelessWidget {
  const ChatSuggestionStrip({
    required this.suggestions,
    required this.onSelected,
    super.key,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            4,
            AppSpacing.lg,
            5,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ActionChip(
              onPressed: () => onSelected(suggestion),
              label: Text(suggestion),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              labelPadding: const EdgeInsets.symmetric(horizontal: 13),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.72),
              side: BorderSide(
                color: AppColors.primaryLight.withValues(alpha: 0.18),
              ),
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
              shape: const StadiumBorder(),
            );
          },
        ),
      ),
    );
  }
}
