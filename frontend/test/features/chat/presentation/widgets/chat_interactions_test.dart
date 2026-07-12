import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_suggestion_strip.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('quick-question tap sends the unchanged question',
      (tester) async {
    String? selected;
    await _pump(
      tester,
      ChatEmptyState(
        quickQuestions: const ['Vehicle status'],
        onQuestionSelected: (value) => selected = value,
      ),
    );

    await tester.tap(find.text('Vehicle status'));

    expect(selected, 'Vehicle status');
  });

  testWidgets('input enables for text and sends from the arrow',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? sent;
    await _pump(
      tester,
      ChatInputBar(
        controller: controller,
        isSending: false,
        onSend: (value) => sent = value,
      ),
    );

    expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '  hello  ');
    await tester.pump();
    await tester.tap(find.byType(IconButton));

    expect(sent, '  hello  ');
  });

  testWidgets('suggestions preserve horizontal swipe scrolling',
      (tester) async {
    await _pump(
      tester,
      ChatSuggestionStrip(
        suggestions: List.generate(12, (index) => 'Suggestion $index'),
        onSelected: (_) {},
      ),
    );
    final listFinder = find.descendant(
      of: find.byType(ChatSuggestionStrip),
      matching: find.byType(Scrollable),
    );
    final scrollable = tester.state<ScrollableState>(listFinder);

    expect(scrollable.position.pixels, 0);
    await tester.drag(listFinder, const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
  });
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}
