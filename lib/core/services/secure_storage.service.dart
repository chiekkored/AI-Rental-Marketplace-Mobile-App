import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef LNDBiometricCredentials = ({String email, String password});

abstract class LNDSecureStorageBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class _FlutterSecureStorageBackend implements LNDSecureStorageBackend {
  const _FlutterSecureStorageBackend();

  static const AndroidOptions _androidOptions = AndroidOptions();

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const WebOptions _webOptions = WebOptions(
    dbName: 'lend_secure_storage',
  );

  FlutterSecureStorage get _storage => const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
    webOptions: _webOptions,
  );

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}

class LNDSecureStorageService {
  LNDSecureStorageService._();

  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';

  static LNDSecureStorageBackend _backend =
      const _FlutterSecureStorageBackend();

  @visibleForTesting
  static void useBackendForTesting(LNDSecureStorageBackend backend) {
    _backend = backend;
  }

  @visibleForTesting
  static void resetBackend() {
    _backend = const _FlutterSecureStorageBackend();
  }

  static Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await Future.wait([
      _backend.write(_biometricEmailKey, email),
      _backend.write(_biometricPasswordKey, password),
    ]);
  }

  static Future<LNDBiometricCredentials?> readBiometricCredentials() async {
    final email = (await _backend.read(_biometricEmailKey))?.trim() ?? '';
    final password = (await _backend.read(_biometricPasswordKey)) ?? '';
    if (email.isEmpty || password.isEmpty) return null;
    return (email: email, password: password);
  }

  static Future<bool> hasBiometricCredentials() async {
    return await readBiometricCredentials() != null;
  }

  static Future<void> clearBiometricCredentials() async {
    await Future.wait([
      _backend.delete(_biometricEmailKey),
      _backend.delete(_biometricPasswordKey),
    ]);
  }

  static Future<void> clearAll() async {
    await _backend.deleteAll();
  }
}
