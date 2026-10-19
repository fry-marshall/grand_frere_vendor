import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/counter_preview.dart';
import '../entities/counter_sale.dart';

abstract class CounterRepository {
  Future<Either<Failure, CounterPreview>> preview(String cardCode);

  /// Sells [lines] on the spot and returns the
  /// created order id and the amount charged.
  Future<Either<Failure, CounterSale>> sell({
    required String cardCode,
    required List<({String itemId, int quantity, int? amount})> lines,
    required String pin,
  });
}
