import '../../../domain/entities/auth_tokens.dart';
import '../../../domain/entities/school.dart';

sealed class SignupVendorState {
  const SignupVendorState();
}

final class SignupVendorInitial extends SignupVendorState {
  const SignupVendorInitial();
}

final class SignupVendorLoadingSchools extends SignupVendorState {
  const SignupVendorLoadingSchools();
}

final class SignupVendorSchoolsLoaded extends SignupVendorState {
  const SignupVendorSchoolsLoaded(this.schools);
  final List<School> schools;
}

final class SignupVendorSubmitting extends SignupVendorState {
  const SignupVendorSubmitting(this.schools);
  final List<School> schools;
}

final class SignupVendorSuccess extends SignupVendorState {
  const SignupVendorSuccess(this.tokens);
  final AuthTokens tokens;
}

final class SignupVendorError extends SignupVendorState {
  const SignupVendorError({required this.message, required this.schools});
  final String message;
  final List<School> schools;
}
