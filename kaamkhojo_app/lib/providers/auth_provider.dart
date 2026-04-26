import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState { unknown, unauthenticated, otpSent, authenticated }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AuthState _state = AuthState.unknown;
  UserModel? _currentUser;
  String? _pendingPhone;
  String? _error;
  bool _loading = false;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get pendingPhone => _pendingPhone;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isNewUser => _currentUser?.hasName == false;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  /// Called at app start — check if we have a stored valid token.
  Future<void> init() async {
    _state = AuthState.unknown;
    notifyListeners();
    try {
      final user = await _authService.getStoredUser();
      if (user != null) {
        _currentUser = user;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> sendOTP(String phone) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendOtp(phone);
      _pendingPhone = phone;
      _state = AuthState.otpSent;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (_pendingPhone == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      final data = await _authService.verifyOtp(_pendingPhone!, otp);
      _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      _state = AuthState.authenticated;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> setRole(String role) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      _currentUser = await _authService.updateProfile({'role': role});
    } catch (_) {}
    _setLoading(false);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.updateProfile(data);
    } catch (_) {}
    _setLoading(false);
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void clearError() => _setError(null);

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'] as String;
    }
    return 'केही समस्या भयो। पुनः प्रयास गर्नुहोस्।';
  }
}
