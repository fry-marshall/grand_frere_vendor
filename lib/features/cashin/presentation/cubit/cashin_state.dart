import '../../domain/entities/order.dart';

sealed class CashinState {
  const CashinState();
}

class CashinInitial extends CashinState {
  const CashinInitial();
}

class CashinLoading extends CashinState {
  const CashinLoading();
}

class CashinOrderFound extends CashinState {
  const CashinOrderFound(this.order);
  final Order order;
}

class CashinCompleting extends CashinState {
  const CashinCompleting(this.order);
  final Order order;
}

class CashinCompleted extends CashinState {
  const CashinCompleted(this.order);
  final Order order;
}

/// The card is valid but the student has no order to cash in: the vendor
/// can switch to a counter sale with the same card.
class CashinNoOrderForCard extends CashinState {
  const CashinNoOrderForCard(this.cardCode);
  final String cardCode;
}

class CashinError extends CashinState {
  const CashinError(this.message);
  final String message;
}
