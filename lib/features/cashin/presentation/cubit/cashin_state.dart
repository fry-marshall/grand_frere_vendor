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

class CashinError extends CashinState {
  const CashinError(this.message);
  final String message;
}
