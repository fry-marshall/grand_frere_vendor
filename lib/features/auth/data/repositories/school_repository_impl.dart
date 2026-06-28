import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/school.dart';
import '../../domain/repositories/school_repository.dart';
import '../datasources/school_remote_datasource.dart';

class SchoolRepositoryImpl implements SchoolRepository {
  const SchoolRepositoryImpl(this._remote);
  final SchoolRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<School>>> getSchools() async {
    try {
      final models = await _remote.getSchools();
      return Right(models.map((m) => m.toDomain()).toList());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
