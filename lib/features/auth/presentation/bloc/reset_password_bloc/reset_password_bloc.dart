import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc(this._repository) : super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitRequested>(_onSubmit);
  }

  final AuthRepository _repository;

  Future<void> _onSubmit(
    ResetPasswordSubmitRequested event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());

    final result = await _repository.resetPassword(
      phone: event.phone,
      code: event.code,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordError(_mapFailure(failure))),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
        NetworkFailure() => 'Pas de connexion internet.',
        _ => failure.message,
      };
}
