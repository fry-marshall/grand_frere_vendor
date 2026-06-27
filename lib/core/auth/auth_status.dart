import 'dart:async';

class AuthStatus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onLogout => _controller.stream;

  void notifyLogout() => _controller.add(null);
}
