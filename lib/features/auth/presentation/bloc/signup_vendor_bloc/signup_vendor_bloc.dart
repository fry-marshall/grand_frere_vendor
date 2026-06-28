import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../domain/entities/school.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/school_repository.dart';
import 'signup_vendor_event.dart';
import 'signup_vendor_state.dart';

class SignupVendorBloc extends Bloc<SignupVendorEvent, SignupVendorState> {
  SignupVendorBloc(this._authRepository, this._schoolRepository)
      : super(const SignupVendorInitial()) {
    on<SignupVendorLoadSchools>(_onLoadSchools);
    on<SignupVendorSubmitRequested>(_onSubmit);
  }

  final AuthRepository _authRepository;
  final SchoolRepository _schoolRepository;

  List<School> _schools = [];

  Future<void> _onLoadSchools(
    SignupVendorLoadSchools event,
    Emitter<SignupVendorState> emit,
  ) async {
    emit(const SignupVendorLoadingSchools());
    final result = await _schoolRepository.getSchools();
    result.fold(
      (failure) => emit(
        SignupVendorError(
          message: _mapFailure(failure),
          schools: const [],
        ),
      ),
      (schools) {
        _schools = schools;
        emit(SignupVendorSchoolsLoaded(schools));
      },
    );
  }

  Future<void> _onSubmit(
    SignupVendorSubmitRequested event,
    Emitter<SignupVendorState> emit,
  ) async {
    emit(SignupVendorSubmitting(_schools));

    final result = await _authRepository.signupVendor(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      password: event.password,
      shopName: event.shopName,
      schoolId: event.schoolId,
      waveNumber: event.waveNumber,
    );

    result.fold(
      (failure) => emit(
        SignupVendorError(
          message: _mapFailure(failure),
          schools: _schools,
        ),
      ),
      (tokens) => emit(SignupVendorSuccess(tokens)),
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
        NetworkFailure() => 'Pas de connexion internet.',
        ConflictFailure() => 'Ce numéro de téléphone est déjà utilisé.',
        NotFoundFailure() => 'École introuvable.',
        ValidationFailure(:final messages) => messages.join('\n'),
        _ => failure.message,
      };
}
