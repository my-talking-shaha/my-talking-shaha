String formatPartsInteger(int value) {
  final prefix = value < 0 ? '-' : '';
  final formatted = value.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );

  return '$prefix$formatted';
}
