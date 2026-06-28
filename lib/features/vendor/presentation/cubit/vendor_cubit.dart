import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/vendor_repository.dart';
import 'vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repo) : super(const VendorInitial());

  final VendorRepository _repo;

  Future<void> load() async {
    emit(const VendorLoading());
    final result = await _repo.getVendor();
    result.fold(
      (failure) => emit(VendorError(failure.message)),
      (vendor) => emit(VendorLoaded(vendor)),
    );
  }

  void reset() => emit(const VendorInitial());
}
