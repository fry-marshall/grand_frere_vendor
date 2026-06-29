import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokens>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, AuthTokens>> signupVendor({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String shopName,
    required String schoolId,
    String? waveNumber,
  });

  Future<Either<Failure, String?>> forgotPassword({required String phone});

  Future<Either<Failure, void>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
