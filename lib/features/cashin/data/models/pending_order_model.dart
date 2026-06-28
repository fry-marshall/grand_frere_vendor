import '../../domain/entities/pending_order.dart';

class PendingOrderModel {
  const PendingOrderModel({
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

  factory PendingOrderModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final user = student['user'] as Map<String, dynamic>;
    final rawItems = json['items'] as List<dynamic>;
    return PendingOrderModel(
      id: json['id'] as String,
      shortCode: json['shortCode'] as String? ?? '',
      studentFirstName: user['firstName'] as String,
      studentLastName: user['lastName'] as String,
      studentClass: student['class'] as String? ?? '',
      totalAmount: json['totalAmount'] as int,
      itemNames: rawItems
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
    );
  }

  PendingOrder toDomain() => PendingOrder(
        id: id,
        shortCode: shortCode,
        studentFirstName: studentFirstName,
        studentLastName: studentLastName,
        studentClass: studentClass,
        totalAmount: totalAmount,
        itemNames: itemNames,
      );
}
