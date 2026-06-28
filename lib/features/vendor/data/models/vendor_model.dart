import '../../domain/entities/vendor.dart';

class VendorModel {
  const VendorModel({
    required this.id,
    required this.shopName,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.waveNumber,
    this.openingTime,
    this.closingTime,
  });

  final String id;
  final String shopName;
  final String status;
  final String firstName;
  final String lastName;
  final String phone;
  final String? waveNumber;
  final String? openingTime;
  final String? closingTime;

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return VendorModel(
      id: json['id'] as String,
      shopName: json['shopName'] as String,
      status: json['status'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      phone: user['phone'] as String,
      waveNumber: json['waveNumber'] as String?,
      openingTime: json['openingTime'] as String?,
      closingTime: json['closingTime'] as String?,
    );
  }

  Vendor toDomain() => Vendor(
        id: id,
        shopName: shopName,
        status: status,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        waveNumber: waveNumber,
        openingTime: openingTime,
        closingTime: closingTime,
      );
}
