import 'package:blithepay/features/auth/data/models/auth_response_model.dart';

class AuthSessionResponse {
  final AuthResponseModel? data;
  final String? message;
  final bool? status;

  const AuthSessionResponse({
    this.data,
    this.message,
    this.status,
  });

  factory AuthSessionResponse.fromJson(Map<String, dynamic> json) {
    return AuthSessionResponse(
      data: json['data'] != null
          ? AuthResponseModel.fromJson(json['data'])
          : null,
      message: json['message'] as String?,
      status: json['status'] as bool?,
    );
  }
}