import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/vendor_item.dart';

abstract class ItemsRepository {
  Future<Either<Failure, List<VendorItem>>> getItems();
  Future<Either<Failure, VendorItem>> createItem(
    String vendorId, {
    required String name,
    required int price,
    String? description,
  });
  Future<Either<Failure, VendorItem>> updateItem(
    String id, {
    String? name,
    int? price,
    String? description,
    String? status,
  });
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, VendorItem>> uploadImage(String id, String filePath);
}
