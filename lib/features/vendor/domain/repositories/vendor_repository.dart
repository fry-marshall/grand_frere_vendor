import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/vendor.dart';
import '../entities/vendor_balance.dart';
import '../entities/vendor_stats.dart';

abstract class VendorRepository {
  Future<Either<Failure, Vendor>> getVendor();
  Future<Either<Failure, VendorStats>> getStats(String id);
  Future<Either<Failure, VendorBalance>> getBalance(String id);
}
