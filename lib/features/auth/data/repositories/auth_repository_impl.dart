import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, AuthTokens>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final model = await _remote.login(phone: phone, password: password);
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      if (e.isUnauthorized) {
        return const Left(ServerFailure('Numéro ou mot de passe incorrect.'));
      }
      if (e.isValidationError) return Left(ValidationFailure(e.messages));
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> signupVendor({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String shopName,
    required String schoolId,
    String? waveNumber,
  }) async {
    try {
      final model = await _remote.signupVendor(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
        shopName: shopName,
        schoolId: schoolId,
        waveNumber: waveNumber,
      );
      return Right(model.toDomain());
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      if (e.isConflict) return Left(ConflictFailure(e.firstMessage));
      if (e.isNotFound) return Left(NotFoundFailure(e.firstMessage));
      if (e.isValidationError) return Left(ValidationFailure(e.messages));
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, String?>> forgotPassword({
    required String phone,
  }) async {
    try {
      final code = await _remote.forgotPassword(phone: phone);
      return Right(code);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      if (e.isNotFound) {
        return const Left(
          NotFoundFailure('Ce numéro n\'est associé à aucun compte.'),
        );
      }
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(
        phone: phone,
        code: code,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) return const Left(NetworkFailure());
      return Left(ServerFailure(e.firstMessage));
    }
  }
}
