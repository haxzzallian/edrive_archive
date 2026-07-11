import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override List<Object> get props => [message];
}

class NetworkFailure       extends Failure { const NetworkFailure([super.message = 'No internet connection']); }
class UnauthorizedFailure  extends Failure { const UnauthorizedFailure([super.message = 'Unauthorized']); }
class NotFoundFailure      extends Failure { const NotFoundFailure([super.message = 'Resource not found']); }
class ValidationFailure    extends Failure { const ValidationFailure([super.message = 'Validation error']); }
class ServerFailure        extends Failure { const ServerFailure([super.message = 'Server error']); }
class UnknownFailure       extends Failure { const UnknownFailure([super.message = 'Unknown error']); }
class LocationFailure      extends Failure { const LocationFailure([super.message = 'Location unavailable']); }
class RideFailure          extends Failure { const RideFailure([super.message = 'Ride error']); }
