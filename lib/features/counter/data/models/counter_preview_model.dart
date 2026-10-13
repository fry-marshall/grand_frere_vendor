import '../../domain/entities/counter_preview.dart';

class CounterPreviewModel extends CounterPreview {
  const CounterPreviewModel({
    required super.studentId,
    required super.firstName,
    required super.lastName,
    required super.spendableToday,
    required super.dailyLimitRemaining,
    super.studentClass,
  });

  factory CounterPreviewModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final user = student['user'] as Map<String, dynamic>;
    return CounterPreviewModel(
      studentId: student['id'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      studentClass: student['class'] as String?,
      spendableToday: (json['spendableToday'] as num).toInt(),
      dailyLimitRemaining: (json['dailyLimitRemaining'] as num).toInt(),
    );
  }
}
