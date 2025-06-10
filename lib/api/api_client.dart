import 'package:dio/dio.dart';
import 'package:smart_home_app/config/env.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage)
      : _dio = Dio(BaseOptions(baseUrl: Env.apiUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Example login method
  Future<Response> login(String email, String password) {
    return _dio.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(String email, String password) {
    return _dio.post('/auth/register/', data: {
      'email': email,
      'password': password,
    });
  }

  // Get current user's info
  Future<Response> getUserInfo() {
    return _dio.get('/auth/me/');
  }

  // Method to fetch devices
  Future<Response> getDevices() {
    return _dio.get('/devices/overview/');
  }

  // --- Device Management ---

  Future<Response> getDeviceDetail(num deviceId) {
    return _dio.get('/devices/$deviceId/detail');
  }
} 