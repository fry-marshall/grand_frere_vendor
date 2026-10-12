import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grand_frere_vendor/core/error/failure.dart';
import 'package:grand_frere_vendor/features/counter/domain/entities/counter_preview.dart';
import 'package:grand_frere_vendor/features/counter/domain/repositories/counter_repository.dart';
import 'package:grand_frere_vendor/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:grand_frere_vendor/features/counter/presentation/cubit/counter_state.dart';
import 'package:grand_frere_vendor/features/menu/domain/entities/vendor_item.dart';

class _FakeCounterRepository implements CounterRepository {
  Either<Failure, CounterPreview> previewResult = const Right(_preview);
  Either<Failure, int> sellResult = const Right(1300);
  Map<String, int>? soldQuantities;
  String? soldPin;

  @override
  Future<Either<Failure, CounterPreview>> preview(String cardCode) async =>
      previewResult;

  @override
  Future<Either<Failure, int>> sell({
    required String cardCode,
    required Map<String, int> quantities,
    required String pin,
  }) async {
    soldQuantities = quantities;
    soldPin = pin;
    return sellResult;
  }
}

const _preview = CounterPreview(
  studentId: 's1',
  firstName: 'Awa',
  lastName: 'Kone',
  spendableToday: 1500,
  dailyLimitRemaining: 3000,
);

final _menu = [
  VendorItem(
    id: 'sandwich',
    vendorId: 'v1',
    name: 'Sandwich',
    price: 500,
    status: 'ACTIVE',
    createdAt: DateTime(2026),
  ),
  VendorItem(
    id: 'juice',
    vendorId: 'v1',
    name: 'Jus',
    price: 300,
    status: 'ACTIVE',
    createdAt: DateTime(2026),
  ),
];

void main() {
  late _FakeCounterRepository repo;
  late CounterCubit cubit;

  setUp(() {
    repo = _FakeCounterRepository();
    cubit = CounterCubit(repo);
  });

  tearDown(() => cubit.close());

  group('lookup', () {
    test('goes to the cart with the student preview', () async {
      await cubit.lookup('CARD', _menu);

      final state = cubit.state as CounterReady;
      expect(state.preview.fullName, 'Awa Kone');
      expect(state.isEmpty, isTrue);
      expect(state.canPay, isFalse);
    });

    test('maps API errors to a French message', () async {
      repo.previewResult = const Left(ServerFailure('Card is not active'));

      await cubit.lookup('CARD', _menu);

      expect(
        (cubit.state as CounterScanError).message,
        "Cette carte n'est pas active.",
      );
    });
  });

  group('cart', () {
    setUp(() => cubit.lookup('CARD', _menu));

    test('computes the total from quantities', () {
      cubit
        ..increment('sandwich')
        ..increment('sandwich')
        ..increment('juice');

      final state = cubit.state as CounterReady;
      expect(state.total, 1300);
      expect(state.itemCount, 3);
      expect(state.canPay, isTrue);
    });

    test('removes an item when its quantity drops to zero', () {
      cubit
        ..increment('juice')
        ..decrement('juice');

      expect((cubit.state as CounterReady).quantities, isEmpty);
    });

    test(
      'blocks payment when the total exceeds what the student can spend',
      () {
        for (var i = 0; i < 4; i++) {
          cubit.increment('sandwich');
        }

        final state = cubit.state as CounterReady;
        expect(state.total, 2000);
        expect(state.exceedsSpendable, isTrue);
        expect(state.canPay, isFalse);
      },
    );
  });

  group('pay', () {
    setUp(() async {
      await cubit.lookup('CARD', _menu);
      cubit
        ..increment('sandwich')
        ..increment('juice');
    });

    test(
      'sends the cart and the PIN, then reports the amount charged',
      () async {
        await cubit.pay('1234');

        expect(repo.soldQuantities, {'sandwich': 1, 'juice': 1});
        expect(repo.soldPin, '1234');
        expect((cubit.state as CounterSold).total, 1300);
      },
    );

    test('keeps the cart when the sale is rejected', () async {
      repo.sellResult = const Left(ServerFailure('Invalid PIN'));

      await cubit.pay('0000');

      final error = cubit.state as CounterSaleError;
      expect(error.message, 'Code PIN incorrect.');

      cubit.dismissError();
      final state = cubit.state as CounterReady;
      expect(state.quantities, {'sandwich': 1, 'juice': 1});
      expect(state.isSubmitting, isFalse);
    });
  });
}
