import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class LNDRemoteConfigException implements Exception {
  final String message;
  final Object? cause;

  const LNDRemoteConfigException(this.message, {this.cause});

  @override
  String toString() {
    if (cause == null) return message;
    return '$message: $cause';
  }
}

class LNDRemoteConfigKey<T> {
  final String name;
  final T Function(String value) parser;
  final bool required;

  const LNDRemoteConfigKey({
    required this.name,
    required this.parser,
    this.required = true,
  });
}

class LNDRemoteConfigService {
  LNDRemoteConfigService._();

  static const pricingPolicyKey = LNDRemoteConfigKey<LNDPricingPolicy>(
    name: 'lend_pricing_policy',
    parser: LNDPricingPolicy.fromJson,
  );

  static final List<LNDRemoteConfigKey<Object>> _startupKeys = [
    pricingPolicyKey,
  ];

  static final Map<String, Object> _cache = {};
  static bool _isReady = false;

  static bool get isReady => _isReady;

  static Future<void> initialize({required String env}) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            env == 'prod'
                ? const Duration(hours: 24)
                : const Duration(minutes: 1),
      ),
    );
    await refreshRequired();
  }

  static Future<void> refreshRequired() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      if (remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.success) {
        throw LNDRemoteConfigException(
          'Remote Config fetch did not succeed (${remoteConfig.lastFetchStatus.name})',
        );
      }

      final nextCache = <String, Object>{};
      for (final key in _startupKeys) {
        nextCache[key.name] = _parseRequired(remoteConfig, key);
      }

      _cache
        ..clear()
        ..addAll(nextCache);
      _isReady = true;
    } catch (e, st) {
      _isReady = false;
      LNDLogger.e('Remote Config fetch failed', error: e, stackTrace: st);
      if (e is LNDRemoteConfigException) rethrow;
      throw LNDRemoteConfigException('Remote Config fetch failed', cause: e);
    }
  }

  static LNDPricingPolicy get pricingPolicy {
    return getRequired(pricingPolicyKey);
  }

  @visibleForTesting
  static void setPricingPolicyForTesting(LNDPricingPolicy policy) {
    _cache[pricingPolicyKey.name] = policy;
    _isReady = true;
  }

  @visibleForTesting
  static void resetForTesting() {
    _cache.clear();
    _isReady = false;
  }

  static T getRequired<T>(LNDRemoteConfigKey<T> key) {
    final value = _cache[key.name];
    if (value is T) return value;

    final message =
        'Remote Config key "${key.name}" was read before startup completed';
    if (kDebugMode) {
      throw StateError(message);
    }
    throw LNDRemoteConfigException(message);
  }

  static Object _parseRequired(
    FirebaseRemoteConfig remoteConfig,
    LNDRemoteConfigKey<Object> key,
  ) {
    final value = remoteConfig.getString(key.name).trim();
    if (key.required && value.isEmpty) {
      throw LNDRemoteConfigException(
        'Required Remote Config key "${key.name}" is missing',
      );
    }

    try {
      return key.parser(value);
    } catch (e, st) {
      LNDLogger.e(
        'Remote Config key "${key.name}" parse failed',
        error: e,
        stackTrace: st,
      );
      throw LNDRemoteConfigException(
        'Remote Config key "${key.name}" is invalid',
        cause: e,
      );
    }
  }
}
