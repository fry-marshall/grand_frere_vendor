sealed class LoginEvent {
  const LoginEvent();
}

final class LoginSubmitRequested extends LoginEvent {
  const LoginSubmitRequested({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;
}
