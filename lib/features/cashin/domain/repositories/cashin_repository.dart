import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failure.dart';
import '../entities/order.dart';
import '../entities/pending_order.dart';

abstract class CashinRepository {
  Future<Either<Failure, String>> scanCard(String cardCode);
  Future<Either<Failure, Order>> getOrderByCard(String cardCode);
  Future<Either<Failure, Order>> getOrderByCode(String code);
  Future<Either<Failure, Unit>> completeOrder(String orderId);
  Future<Either<Failure, List<PendingOrder>>> getPendingOrders(String vendorId);
}
