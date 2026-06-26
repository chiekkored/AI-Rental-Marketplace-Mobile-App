import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/services/secure_storage.service.dart';

class _MemorySecureStorageBackend implements LNDSecureStorageBackend {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

void main() {
  late _MemorySecureStorageBackend backend;

  setUp(() {
    backend = _MemorySecureStorageBackend();
    LNDSecureStorageService.useBackendForTesting(backend);
  });

  tearDown(() {
    LNDSecureStorageService.resetBackend();
  });

  test('saves, reads, and clears biometric credentials', () async {
    await LNDSecureStorageService.saveBiometricCredentials(
      email: 'user@example.com',
      password: 'secret',
    );

    final credentials =
        await LNDSecureStorageService.readBiometricCredentials();

    expect(credentials, isNotNull);
    expect(credentials?.email, 'user@example.com');
    expect(credentials?.password, 'secret');
    expect(await LNDSecureStorageService.hasBiometricCredentials(), isTrue);

    await LNDSecureStorageService.clearBiometricCredentials();

    expect(await LNDSecureStorageService.readBiometricCredentials(), isNull);
    expect(await LNDSecureStorageService.hasBiometricCredentials(), isFalse);
  });
}
