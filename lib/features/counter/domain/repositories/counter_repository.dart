import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/counter_preview.dart';

abstract class CounterRepository {
  Future<Either<Failure, CounterPreview>> preview(String cardCode);

  /// Sells [quantities] (itemId → quantity) on the spot and returns the
  /// amount charged.
  Future<Either<Failure, int>> sell({
    required String cardCode,
    required Map<String, int> quantities,
    required String pin,
  });
}
