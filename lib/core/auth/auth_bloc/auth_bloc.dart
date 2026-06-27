import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_status.dart';
import '../user_role.dart';
import '../../storage/token_storage.dart';
import '../../utils/jwt_decoder.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._tokenStorage, this._authStatus) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _logoutSub = _authStatus.onLogout.listen(
      (_) => add(const AuthLogoutRequested()),
    );
  }

  final TokenStorage _tokenStorage;
  final AuthStatus _authStatus;
  late final StreamSubscription<void> _logoutSub;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final token = await _tokenStorage.getAccessToken();
    final roleStr = await _tokenStorage.getRole();
    if (token == null || roleStr == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    final role = UserRole.values.where((r) => r.name == roleStr).firstOrNull;
    if (role == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(role));
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final role = JwtDecoder.extractRole(event.accessToken);
    if (role == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    await _tokenStorage.saveTokens(
      accessToken: event.accessToken,
      refreshToken: event.refreshToken,
      role: role.name,
    );
    emit(AuthAuthenticated(role));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenStorage.clearTokens();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _logoutSub.cancel();
    return super.close();
  }
}
