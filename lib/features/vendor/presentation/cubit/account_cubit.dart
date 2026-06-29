import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/vendor_repository.dart';
import 'account_state.dart';
import 'vendor_cubit.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._vendorRepo, this._authRepo, this._vendorCubit)
      : super(AccountIdle());

  final VendorRepository _vendorRepo;
  final AuthRepository _authRepo;
  final VendorCubit _vendorCubit;

  Future<void> updateProfile(
    String vendorId, {
    String? shopName,
    String? waveNumber,
    String? openingTime,
    String? closingTime,
  }) async {
    emit(AccountSaving());
    final result = await _vendorRepo.updateVendor(
      vendorId,
      shopName: shopName,
      waveNumber: waveNumber,
      openingTime: openingTime,
      closingTime: closingTime,
    );
    result.fold(
      (f) => emit(AccountError(f.message)),
      (_) {
        _vendorCubit.load();
        emit(AccountSuccess());
      },
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(AccountSaving());
    final result = await _authRepo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    result.fold(
      (f) => emit(AccountError(f.message)),
      (_) => emit(AccountSuccess()),
    );
  }

  void reset() => emit(AccountIdle());
}
