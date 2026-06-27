class ServerException {
  const ServerException(this.message);
  final String message;
}

class NetworkException {
  const NetworkException();
}

class ForbiddenException {
  const ForbiddenException();
}

class UnauthorizedException {
  const UnauthorizedException();
}

class CacheException {
  const CacheException(this.message);
  final String message;
}
