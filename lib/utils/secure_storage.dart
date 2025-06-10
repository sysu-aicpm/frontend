import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';

// class SecureStorage {
//   final _storage = const FlutterSecureStorage();

//   static const _tokenKey = 'auth_token';

//   Future<void> saveToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//   }

//   Future<String?> getToken() async {
//     return await _storage.read(key: _tokenKey);
//   }

//   Future<void> deleteToken() async {
//     await _storage.delete(key: _tokenKey);
//   }
// } 

class SecureStorage {
  static const _tokenKey = "ACCESS_TOKEN_KEY";
  final FlutterSecureStorage _secureStorage;
  final _accessTokenLock = Lock();
  
  static final SecureStorage _instance = SecureStorage._();
  
  factory SecureStorage() => _instance;

  SecureStorage._() : _secureStorage = const FlutterSecureStorage(
    // aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // mOptions: MacOsOptions(groupId: 'basis-keychain'),
  );

  Future<void> saveToken(String accessToken) async {
    await _accessTokenLock.synchronized(() async {
      await _secureStorage.write(key: _tokenKey, value: accessToken);
    });
  }

  Future<String?> getToken() async {
    return await _accessTokenLock.synchronized(() async {
      final data = await _secureStorage.readAll();
      return data[_tokenKey];
    });
  }

  Future<void> deleteToken() async {
    await _accessTokenLock.synchronized(() async {
      await _secureStorage.delete(key: _tokenKey);
    });
  }
}