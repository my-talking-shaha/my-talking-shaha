import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_assistant_mark.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    required this.quickQuestions,
    required this.onQuestionSelected,
    super.key,
  });

  final List<String> quickQuestions;
  final ValueChanged<String> onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questions = quickQuestions.isEmpty
        ? [
            l10n.quickQuestionVehicleStatus,
            l10n.quickQuestionOil,
            l10n.quickQuestionBreakSoon,
          ]
        : quickQuestions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        const SizedBox(height: 72),
        const ChatAssistantMark(size: 84, iconSize: 38),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.shahaOnline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.chatEmptyDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        ...questions.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _QuickQuestionTile(
              question: question,
              onTap: () => onQuestionSelected(question),
            ),
          ),
        ),
      ],
    );
  }
}

final class _QuickQuestionTile extends StatelessWidget {
  const _QuickQuestionTile({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(question, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
