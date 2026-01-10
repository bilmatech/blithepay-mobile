import 'package:equatable/equatable.dart';

abstract class NetworkException extends Equatable implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerException extends NetworkException {
  const ServerException({required String message}) : super(message: message);
}

class CacheException extends NetworkException {
  const CacheException({required String message}) : super(message: message);
}

class NetworkError extends NetworkException {
  const NetworkError({required String message}) : super(message: message);
}

class BadRequestException extends NetworkException {
  const BadRequestException({required String message}) : super(message: message);
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({required String message}) : super(message: message);
}

class NotFoundException extends NetworkException {
  const NotFoundException({required String message}) : super(message: message);
}

class TimeoutException extends NetworkException {
  const TimeoutException({required String message}) : super(message: message);
}
