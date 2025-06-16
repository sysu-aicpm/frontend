import 'package:dio/dio.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/config/env.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

class ApiClient {
  Dio _dio;
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

  void setAPIURL(String url) {
    _dio = Dio(BaseOptions(baseUrl: url));
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

  // --------- Authorization ---------

  Future<Response> login(String email, String password) {
    return _dio.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });
  }

  // TODO: 补充 first_name last_name
  Future<Response> register(String email, String password, String username) {
    return _dio.post('/auth/register/', data: {
      'email': email,
      'password': password,
      'username': username,
    });
  }

  Future<Response> getUserInfo() {
    return _dio.get('/auth/me/');
  }

  // --------- Device Management ---------

  Future<Response> getDevices() {
    return _dio.get('/devices/overview/');
  }

  Future<Response> getDeviceDetail(num deviceId) {
    return _dio.get('/devices/$deviceId/detail');
  }

  // TODO: 控制设备 /devices/$deviceId/control

  // --------- Admin Management ---------
  // 以下部分仅限 is_staff 的管理员用户可调用
  // TODO: 考虑用另一个 api client 操作这部分

  // --------- Admin Device Groups ---------

  Future<Response> getDeviceGroups() {
    return _dio.get('/device-groups/');
  }

  Future<Response> createDeviceGroup(String name, String? description) {
    var data = {'name': name};
    if (description != null) data['description'] = description;
    return _dio.post('/device-groups/', data: data);
  }

  Future<Response> deleteDeviceGroup(num deviceGroupId) {
    return _dio.delete('/device-groups/$deviceGroupId/');
  }

  Future<Response> updateDeviceGroupName(num deviceGroupId, String name, String? description) {
    var data = {'name': name};
    if (description != null) data['description'] = description;
    return _dio.put('/device-groups/$deviceGroupId/', data: data);
  }

  Future<Response> addDeviceToDeviceGroup(num deviceGroupId, num deviceId) {
    return _dio.post('/device-groups/$deviceGroupId/devices/', data: {
      "device_id": deviceId
    });
  }

  Future<Response> rmDeviceFromDeviceGroup(num deviceGroupId, num deviceId) {
    return _dio.delete('/device-groups/$deviceGroupId/devices/$deviceId/');
  }

  // --------- Admin Users ---------

  Future<Response> getUsers() {
    return _dio.get('/auth/all/');
  }

  Future<Response> getUserPermissionOnDevices(num userId) {
    return _dio.get('/permissions/user/$userId/');
  }

  Future<Response> updateUserPermissionOnDevice(num userId, PermissionLevel level, num deviceId) {
    return _dio.put('/permissions/user/$userId/', data: {
      "device_id": deviceId,
      "permission_level": level.name
    });
  }

  Future<Response> getUserPermissionOnDeviceGroups(num userId) {
    return _dio.get('/permissions/device-groups/user/$userId/');
  }

  Future<Response> updateUserPermissionOnDeviceGroup(num userId, PermissionLevel level, num deviceGroupId) {
    return _dio.put('/permissions/device-groups/user/$userId/', data: {
      "device_group_id": deviceGroupId,
      "permission_level": level.name
    });
  }

  // --------- Admin User Groups ---------

  Future<Response> getUserGroups() {
    return _dio.get('/user-groups/');
  }

  Future<Response> createUserGroup(String name, String? description) {
    var data = {'name': name};
    if (description != null) data['description'] = description;
    return _dio.post('/user-groups/', data: data);
  }

  Future<Response> deleteUserGroup(num userGroupId) {
    return _dio.delete('/user-groups/$userGroupId/');
  }

  Future<Response> updateUserGroupName(num userGroupId, String name, String? description) {
    var data = {'name': name};
    if (description != null) data['description'] = description;
    return _dio.post('/user-groups/$userGroupId/', data: data);
  }

  Future<Response> addUserToUserGroup(num userGroupId, num userId) {
    return _dio.post('/user-groups/$userGroupId/members/', data: {
      "user_id": userId
    });
  }

  Future<Response> rmUserFromUserGroup(num userGroupId, num userId) {
    return _dio.delete('/user-groups/$userGroupId/members/$userId/');
  }

  Future<Response> getUserGroupPermissionOnDevices(num userGroupId) {
    return _dio.get('/permissions/user-groups/$userGroupId/');
  }

  Future<Response> updateUserGroupPermissionOnDevice(num userGroupId, PermissionLevel level, num deviceId) {
    return _dio.put('/permissions/user-groups/$userGroupId/', data: {
      "device_id": deviceId,
      "permission_level": level.name
    });
  }

  Future<Response> getUserGroupPermissionOnDeviceGroups(num userGroupId) {
    return _dio.get('/permissions/device-groups/user-groups/$userGroupId/');
  }

  Future<Response> updateUserGroupPermissionOnDeviceGroup(num userGroupId, PermissionLevel level, num deviceGroupId) {
    return _dio.put('/permissions/device-groups/user-groups/$userGroupId/', data: {
      "device_group_id": deviceGroupId,
      "permission_level": level.name
    });
  }
} 