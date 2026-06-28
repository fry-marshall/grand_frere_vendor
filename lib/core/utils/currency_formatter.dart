String formatXof(int amount) {
  final s = amount.abs().toString();
  final groups = <String>[];
  for (int i = s.length; i > 0; i -= 3) {
    groups.add(s.substring(i < 3 ? 0 : i - 3, i));
  }
  final formatted = groups.reversed.join(' ');
  return amount < 0 ? '-$formatted' : formatted;
}
