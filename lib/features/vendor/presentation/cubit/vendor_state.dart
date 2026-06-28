import '../../domain/entities/vendor.dart';

sealed class VendorState {
  const VendorState();
}

class VendorInitial extends VendorState {
  const VendorInitial();
}

class VendorLoading extends VendorState {
  const VendorLoading();
}

class VendorLoaded extends VendorState {
  const VendorLoaded(this.vendor);
  final Vendor vendor;
}

class VendorError extends VendorState {
  const VendorError(this.message);
  final String message;
}
