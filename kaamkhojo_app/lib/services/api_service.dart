import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      _AuthInterceptor(_storage, _tokenKey, _refreshKey),
      LogInterceptor(responseBody: false, requestBody: false),
    ]);

  Dio get client => _dio;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshKey),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final String _tokenKey;
  final String _refreshKey;

  _AuthInterceptor(this._storage, this._tokenKey, this._refreshKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try token refresh
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${AppConfig.apiBaseUrl}/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );
          final newToken = response.data['accessToken'] as String;
          await _storage.write(key: _tokenKey, value: newToken);

          // Retry original request
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await Dio().fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}
