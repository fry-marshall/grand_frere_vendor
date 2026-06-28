class Vendor {
  const Vendor({
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

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
