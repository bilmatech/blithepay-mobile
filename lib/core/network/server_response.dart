import 'package:equatable/equatable.dart';

class ServerResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  const ServerResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ServerResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ServerResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }

  @override
  List<Object?> get props => [success, message, data, error];
}
