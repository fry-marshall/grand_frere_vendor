import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../../vendor/domain/entities/vendor_balance.dart';
import '../../domain/entities/vendor_withdrawal.dart';
import '../../domain/repositories/balance_repository.dart';
import '../datasources/balance_remote_datasource.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  const BalanceRepositoryImpl(this._ds);
  final BalanceRemoteDataSource _ds;

  @override
  Future<Either<Failure, VendorBalance>> getBalance(String vendorId) async {
    try {
      final model = await _ds.getBalance(vendorId);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, List<VendorWithdrawal>>> getWithdrawals(
    String vendorId,
  ) async {
    try {
      return Right(await _ds.getWithdrawals(vendorId));
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorWithdrawal>> createWithdrawal(
    String vendorId, {
    required int amount,
    required String waveNumber,
  }) async {
    try {
      return Right(
        await _ds.createWithdrawal(vendorId, amount: amount, waveNumber: waveNumber),
      );
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
