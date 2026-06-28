import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
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
      (tokens) => emit(LoginSuccess(tokens)),
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
        NetworkFailure() => 'Pas de connexion internet.',
        ValidationFailure(:final messages) => messages.join('\n'),
        _ => failure.message,
      };
}
