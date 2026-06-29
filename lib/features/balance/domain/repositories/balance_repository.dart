import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../vendor/domain/entities/vendor_balance.dart';
import '../entities/vendor_withdrawal.dart';

abstract class BalanceRepository {
  Future<Either<Failure, VendorBalance>> getBalance(String vendorId);
  Future<Either<Failure, List<VendorWithdrawal>>> getWithdrawals(String vendorId);
  Future<Either<Failure, VendorWithdrawal>> createWithdrawal(
    String vendorId, {
    required int amount,
    required String waveNumber,
  });
}
