import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRepositoryInterface {
  Future<AuthResponseModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
  );
  Future<AuthResponseModel> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String code);
  Future<void> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  );
  Future<void> logout();
}

class AuthRepository implements AuthRepositoryInterface {
  final DioClient _dioClient;

  AuthRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  @override
  Future<AuthResponseModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return AuthResponseModel.fromJson(data);
      }
      throw const ServerException(message: 'Failed to sign up');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      // Mock response for demo
      await Future.delayed(const Duration(seconds: 1));

      return AuthResponseModel(
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        user: UserModel(
          id: '1',
          email: email,
          fullName: 'User Name',
          emailVerified: true,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw const ServerException(message: 'Login failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> verifyOtp(String email, String code) async {
    try {
      // Mock OTP verification
      await Future.delayed(const Duration(milliseconds: 500));
      if (code.length != 4) {
        throw const BadRequestException(message: 'Invalid code');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  NetworkException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException(message: 'Connection timeout');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkError(message: 'Network error');
    }
    if (e.response?.statusCode == 401) {
      return const UnauthorizedException(message: 'Unauthorized');
    }
    if (e.response?.statusCode == 400) {
      return BadRequestException(
        message: e.response?.data['message'] ?? 'Bad request',
      );
    }
    return ServerException(message: e.message ?? 'Unknown error');
  }
}
