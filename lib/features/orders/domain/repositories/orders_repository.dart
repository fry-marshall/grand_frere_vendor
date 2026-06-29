import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/vendor_order.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<VendorOrder>>> getOrders(String vendorId);
  Future<Either<Failure, void>> validateOrder(String orderId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
