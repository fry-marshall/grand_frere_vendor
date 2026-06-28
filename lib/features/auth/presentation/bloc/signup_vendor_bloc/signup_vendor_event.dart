sealed class SignupVendorEvent {
  const SignupVendorEvent();
}

final class SignupVendorLoadSchools extends SignupVendorEvent {
  const SignupVendorLoadSchools();
}

final class SignupVendorSubmitRequested extends SignupVendorEvent {
  const SignupVendorSubmitRequested({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.shopName,
    required this.schoolId,
    this.waveNumber,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String shopName;
  final String schoolId;
  final String? waveNumber;
}
