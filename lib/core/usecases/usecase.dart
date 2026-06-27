import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
