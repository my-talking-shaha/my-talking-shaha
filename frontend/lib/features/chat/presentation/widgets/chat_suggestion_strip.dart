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
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ActionChip(
              onPressed: () => onSelected(suggestion),
              label: Text(suggestion),
              backgroundColor: AppColors.surfaceHigh,
              side: BorderSide(
                color: AppColors.primaryLight.withValues(alpha: 0.22),
              ),
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              shape: const StadiumBorder(),
            );
          },
        ),
      ),
    );
  }
}
