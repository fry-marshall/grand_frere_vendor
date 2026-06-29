import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vendor_order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._ds);
  final OrdersRemoteDataSource _ds;

  @override
  Future<Either<Failure, List<VendorOrder>>> getOrders(String vendorId) async {
    try {
      final orders = await _ds.getOrders(vendorId);
      return Right(orders);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, void>> validateOrder(String orderId) async {
    try {
      await _ds.validateOrder(orderId);
      return const Right(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await _ds.cancelOrder(orderId);
      return const Right(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
