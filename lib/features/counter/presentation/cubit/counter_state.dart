import '../../../menu/domain/entities/vendor_item.dart';
import '../../domain/entities/counter_preview.dart';

sealed class CounterState {
  const CounterState();
}

/// Waiting for a card to be scanned.
class CounterScanning extends CounterState {
  const CounterScanning();
}

class CounterLoadingPreview extends CounterState {
  const CounterLoadingPreview();
}

/// The scan failed (unknown card, inactive card, other school…).
class CounterScanError extends CounterState {
  const CounterScanError(this.message);
  final String message;
}

/// Student identified: the vendor builds the cart.
class CounterReady extends CounterState {
  const CounterReady({
    required this.cardCode,
    required this.preview,
    required this.menu,
    this.quantities = const {},
    this.isSubmitting = false,
  });

  final String cardCode;
  final CounterPreview preview;
  final List<VendorItem> menu;

  /// itemId → taps on + (the quantity, or the steps for a variable price).
  final Map<String, int> quantities;
  final bool isSubmitting;

  int get total => menu.fold(
    0,
    (sum, item) => sum + item.amountFor(quantities[item.id] ?? 0),
  );

  /// A variable-price item counts as one, whatever its amount.
  int get itemCount => menu.fold(0, (sum, item) {
    final units = quantities[item.id] ?? 0;
    return sum + (item.isVariablePrice && units > 0 ? 1 : units);
  });

  /// Lines sent to the API: the picked amount for a variable-price item,
  /// the quantity otherwise.
  List<({String itemId, int quantity, int? amount})> get lines => [
    for (final item in menu)
      if ((quantities[item.id] ?? 0) > 0)
        item.isVariablePrice
            ? (
                itemId: item.id,
                quantity: 1,
                amount: item.amountFor(quantities[item.id]!),
              )
            : (itemId: item.id, quantity: quantities[item.id]!, amount: null),
  ];

  bool get isEmpty => quantities.isEmpty;

  bool get exceedsSpendable => total > preview.spendableToday;

  bool get canPay => !isEmpty && !exceedsSpendable && !isSubmitting;

  CounterReady copyWith({Map<String, int>? quantities, bool? isSubmitting}) {
    return CounterReady(
      cardCode: cardCode,
      preview: preview,
      menu: menu,
      quantities: quantities ?? this.quantities,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// The sale was rejected: the cart is kept so the vendor can retry.
class CounterSaleError extends CounterState {
  const CounterSaleError({required this.message, required this.previous});
  final String message;
  final CounterReady previous;
}

class CounterSold extends CounterState {
  const CounterSold({
    required this.preview,
    required this.orderId,
    required this.total,
  });
  final CounterPreview preview;
  final String orderId;
  final int total;
}
