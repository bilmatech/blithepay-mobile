import 'package:equatable/equatable.dart';

abstract class NetworkException extends Equatable implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerException extends NetworkException {
  const ServerException({required super.message});
}

class CacheException extends NetworkException {
  const CacheException({required super.message});
}

class NetworkError extends NetworkException {
  const NetworkError({required super.message});
}

class BadRequestException extends NetworkException {
  const BadRequestException({required super.message});
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({required super.message});
}

class NotFoundException extends NetworkException {
  const NotFoundException({required super.message});
}

class TimeoutException extends NetworkException {
  const TimeoutException({required super.message});
}
