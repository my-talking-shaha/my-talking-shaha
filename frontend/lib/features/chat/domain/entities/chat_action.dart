final class ChatAction {
  const ChatAction({
    required this.type,
    required this.prefill,
    this.form,
    this.screen,
  });

  final String type;
  final String? form;
  final String? screen;
  final Map<String, Object?> prefill;
}
