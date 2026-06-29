sealed class AccountState {}

class AccountIdle extends AccountState {}

class AccountSaving extends AccountState {}

class AccountSuccess extends AccountState {}

class AccountError extends AccountState {
  AccountError(this.message);
  final String message;
}
