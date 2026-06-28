import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/school.dart';

abstract class SchoolRepository {
  Future<Either<Failure, List<School>>> getSchools();
}
