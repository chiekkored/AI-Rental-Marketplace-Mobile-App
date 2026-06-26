import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';

class LNDStorageService {
  static final GetStorage _box = GetStorage();

  // Write a value
  static Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // Write a list value
  static Future<void> writeList(String key, List<dynamic> value) async {
    await _box.write(key, value);
  }

  // Read a value
  static T? read<T>(String key) {
    return _box.read<T>(key);
  }

  // Read list value
  static List<dynamic>? readList(String key) {
    return _box.read<List<dynamic>>(key);
  }

  // Remove a value
  static Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // Listen to changes
  static void listen(void Function() callback) {
    _box.listen(callback);
  }

  // Listen to changes on a specific key
  static VoidCallback listenKey(String key, void Function(dynamic) callback) {
    return _box.listenKey(key, callback);
  }

  // Clear all stored data
  static Future<void> clear() async {
    await _box.erase();
  }

  static Iterable<String> keys() {
    return _box.getKeys<Iterable>().cast<String>();
  }

  static Future<void> clearSessionData() async {
    final preservedKeys = {
      LNDStorageConstants.themeMode,
      LNDStorageConstants.enableBiometrics,
      LNDStorageConstants.selectedIddCountryCode,
      LNDStorageConstants.selectedCurrencyCountryCode,
      LNDStorageConstants.selectedCurrencyCode,
      LNDStorageConstants.onboardingComplete,
    };

    final allKeys = keys().toList(growable: false);
    for (final key in allKeys) {
      if (preservedKeys.contains(key)) continue;
      if (key.startsWith(
        LNDStorageConstants.publishListingDisclaimerAcknowledged,
      )) {
        continue;
      }
      await remove(key);
    }
  }
}
