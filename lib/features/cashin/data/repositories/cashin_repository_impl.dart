import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/pending_order.dart';
import '../../domain/repositories/cashin_repository.dart';
import '../datasources/cashin_remote_datasource.dart';

class CashinRepositoryImpl implements CashinRepository {
  const CashinRepositoryImpl(this._remote);
  final CashinRemoteDataSource _remote;

  @override
  Future<Either<Failure, String>> scanCard(String cardCode) async {
    try {
      final status = await _remote.scanCard(cardCode);
      return Right(status);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderByCard(String cardCode) async {
    try {
      final model = await _remote.getOrderByCard(cardCode);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderByCode(String code) async {
    try {
      final model = await _remote.getOrderByCode(code);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeOrder(String orderId) async {
    try {
      await _remote.completeOrder(orderId);
      return const Right(unit);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, List<PendingOrder>>> getPendingOrders(String vendorId) async {
    try {
      final models = await _remote.getPendingOrders(vendorId);
      return Right(models.map((m) => m.toDomain()).toList());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
