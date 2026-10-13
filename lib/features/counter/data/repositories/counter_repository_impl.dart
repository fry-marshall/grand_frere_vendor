import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/counter_preview.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_remote_datasource.dart';

class CounterRepositoryImpl implements CounterRepository {
  const CounterRepositoryImpl(this._remote);
  final CounterRemoteDataSource _remote;

  @override
  Future<Either<Failure, CounterPreview>> preview(String cardCode) async {
    try {
      return Right(await _remote.preview(cardCode));
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, int>> sell({
    required String cardCode,
    required Map<String, int> quantities,
    required String pin,
  }) async {
    try {
      return Right(
        await _remote.sell(
          cardCode: cardCode,
          quantities: quantities,
          pin: pin,
        ),
      );
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
