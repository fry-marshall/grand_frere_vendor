import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc(this._repository) : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitRequested>(_onSubmit);
  }

  final AuthRepository _repository;

  Future<void> _onSubmit(
    ForgotPasswordSubmitRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    final result = await _repository.forgotPassword(phone: event.phone);

    result.fold(
      (failure) => emit(ForgotPasswordError(_mapFailure(failure))),
      (code) => emit(ForgotPasswordOtpReceived(phone: event.phone, code: code)),
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
        NetworkFailure() => 'Pas de connexion internet.',
        NotFoundFailure(:final message) => message,
        _ => failure.message,
      };
}
