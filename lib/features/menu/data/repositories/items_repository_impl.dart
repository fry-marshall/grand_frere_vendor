import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vendor_item.dart';
import '../../domain/repositories/items_repository.dart';
import '../datasources/items_remote_datasource.dart';

class ItemsRepositoryImpl implements ItemsRepository {
  const ItemsRepositoryImpl(this._ds);
  final ItemsRemoteDataSource _ds;

  @override
  Future<Either<Failure, List<VendorItem>>> getItems() async {
    try {
      return Right(await _ds.getItems());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorItem>> createItem(
    String vendorId, {
    required String name,
    required int price,
    String? description,
  }) async {
    try {
      return Right(
        await _ds.createItem(vendorId, name: name, price: price, description: description),
      );
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorItem>> updateItem(
    String id, {
    String? name,
    int? price,
    String? description,
    String? status,
  }) async {
    try {
      return Right(
        await _ds.updateItem(id, name: name, price: price, description: description, status: status),
      );
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      await _ds.deleteItem(id);
      return const Right(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, VendorItem>> uploadImage(String id, String filePath) async {
    try {
      return Right(await _ds.uploadImage(id, filePath));
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
