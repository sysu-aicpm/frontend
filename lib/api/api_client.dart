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

  // Get current user's info
  Future<Response> getUserInfo() {
    return _dio.get('/auth/me/');
  }

  // Method to fetch devices
  Future<Response> getDevices() {
    return _dio.get('/devices');
  }

  // --- Permission Management (Simulated) ---

  // Get all permissions for a specific device
  Future<Response> getDevicePermissions(String deviceId) async {
    print('Simulating GET /api/devices/$deviceId/user-permissions/');
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: [
        {'id': 'perm1', 'user': {'id': 'user2', 'username': 'bob'}, 'permission_level': 'usable'},
        {'id': 'perm2', 'user': {'id': 'user3', 'username': 'charlie'}, 'permission_level': 'configurable'},
      ]
    );
  }

  // Search for users to share with
  Future<Response> searchUsers(String query) async {
    print('Simulating GET /api/users/search?q=$query');
    await Future.delayed(const Duration(milliseconds: 300));
     return Response(
      requestOptions: RequestOptions(path: ''),
      data: [
        {'id': 'user4', 'username': '${query}_user_1'},
        {'id': 'user5', 'username': '${query}_user_2'},
      ]
    );
  }

  // Share a device with another user
  Future<Response> shareDevice(String deviceId, String userId, String permissionLevel) async {
    print('Simulating POST /api/devices/$deviceId/user-permissions/ with userId: $userId, level: $permissionLevel');
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(requestOptions: RequestOptions(path: ''), statusCode: 201);
  }

  // Revoke a permission
  Future<Response> revokePermission(String permissionId) async {
    print('Simulating DELETE /api/user-device-permissions/$permissionId/');
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(requestOptions: RequestOptions(path: ''), statusCode: 204);
  }
} 