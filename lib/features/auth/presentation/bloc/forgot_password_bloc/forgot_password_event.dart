sealed class ForgotPasswordEvent {
  const ForgotPasswordEvent();
}

final class ForgotPasswordSubmitRequested extends ForgotPasswordEvent {
  const ForgotPasswordSubmitRequested({required this.phone});
  final String phone;
}
