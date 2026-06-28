import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/entities/vendor_balance.dart';
import '../../domain/entities/vendor_stats.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  const VendorRepositoryImpl(this._remote);
  final VendorRemoteDataSource _remote;

  @override
  Future<Either<Failure, Vendor>> getVendor() async {
    try {
      final model = await _remote.getVendor();
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorStats>> getStats(String id) async {
    try {
      final model = await _remote.getStats(id);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorBalance>> getBalance(String id) async {
    try {
      final model = await _remote.getBalance(id);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
