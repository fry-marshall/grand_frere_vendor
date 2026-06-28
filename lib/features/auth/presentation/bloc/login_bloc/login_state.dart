import '../../../domain/entities/auth_tokens.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.tokens);
  final AuthTokens tokens;
}

final class LoginError extends LoginState {
  const LoginError(this.message);
  final String message;
}
