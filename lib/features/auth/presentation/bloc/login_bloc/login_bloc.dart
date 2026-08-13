import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/utils/jwt_decoder.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._repository) : super(const LoginInitial()) {
    on<LoginSubmitRequested>(_onSubmit);
  }

  final AuthRepository _repository;

  Future<void> _onSubmit(
    LoginSubmitRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _repository.login(
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(LoginError(_mapFailure(failure))),
      (tokens) {
        // This app is vendor-only: reject accounts issued for the other
        // roles (e.g. a parent/student account) instead of letting them
        // through with a token whose role the rest of the app never checks.
        if (JwtDecoder.extractRole(tokens.accessToken) != UserRole.vendor) {
          emit(
            const LoginError(
              "Ce compte n'est pas un compte vendeur. "
              "Connectez-vous avec un compte vendeur.",
            ),
          );
          return;
        }
        emit(LoginSuccess(tokens));
      },
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
        NetworkFailure() => 'Pas de connexion internet.',
        ValidationFailure(:final messages) => messages.join('\n'),
        _ => failure.message,
      };
}
