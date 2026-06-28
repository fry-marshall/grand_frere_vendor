class PendingOrder {
  const PendingOrder({
    required this.id,
    required this.shortCode,
    required this.studentFirstName,
    required this.studentLastName,
    required this.studentClass,
    required this.totalAmount,
    required this.itemNames,
  });

  final String id;
  final String shortCode;
  final String studentFirstName;
  final String studentLastName;
  final String studentClass;
  final int totalAmount;
  final List<String> itemNames;

  String get studentFullName => '$studentFirstName $studentLastName';
  String get itemsSummary => itemNames.take(3).join(' · ');
}
