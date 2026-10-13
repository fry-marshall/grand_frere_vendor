class CounterPreview {
  const CounterPreview({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.spendableToday,
    required this.dailyLimitRemaining,
    this.studentClass,
  });

  final String studentId;
  final String firstName;
  final String lastName;
  final String? studentClass;

  /// What the student can spend right now (lowest of the available balance
  /// and what is left of the card daily limit). The wallet balance itself is
  /// never sent to the vendor.
  final int spendableToday;
  final int dailyLimitRemaining;

  String get fullName => '$firstName $lastName';
}
