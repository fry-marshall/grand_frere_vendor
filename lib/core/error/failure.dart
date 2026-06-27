import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super('Access denied');
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.messages) : super('Validation error');
  final List<String> messages;
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
