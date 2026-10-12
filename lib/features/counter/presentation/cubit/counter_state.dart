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

  /// itemId → quantity (only items with a quantity > 0).
  final Map<String, int> quantities;
  final bool isSubmitting;

  int get total => menu.fold(
    0,
    (sum, item) => sum + item.price * (quantities[item.id] ?? 0),
  );

  int get itemCount => quantities.values.fold(0, (a, b) => a + b);

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
  const CounterSold({required this.preview, required this.total});
  final CounterPreview preview;
  final int total;
}
