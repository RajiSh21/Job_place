import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService.instance;

  Future<void> sendOtp(String phone) async {
    await _api.client.post('/auth/send-otp', data: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _api.client.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    final data = response.data as Map<String, dynamic>;
    await _api.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
    return data;
  }

  Future<UserModel?> getStoredUser() async {
    final token = await _api.getAccessToken();
    if (token == null) return null;
    try {
      final response = await _api.client.get('/users/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.client.put('/users/profile', data: data);
    return UserModel.fromJson(
      (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }
}
