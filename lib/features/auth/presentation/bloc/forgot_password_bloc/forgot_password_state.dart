sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

final class ForgotPasswordOtpReceived extends ForgotPasswordState {
  const ForgotPasswordOtpReceived({required this.phone, this.code});
  final String phone;
  final String? code;
}

final class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError(this.message);
  final String message;
}
