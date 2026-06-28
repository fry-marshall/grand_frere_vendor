sealed class ResetPasswordEvent {
  const ResetPasswordEvent();
}

final class ResetPasswordSubmitRequested extends ResetPasswordEvent {
  const ResetPasswordSubmitRequested({
    required this.phone,
    required this.code,
    required this.newPassword,
  });

  final String phone;
  final String code;
  final String newPassword;
}
