import 'package:cloud_firestore/cloud_firestore.dart';

class LNDPaymentMethodConfig {
  final Map<String, LNDPaymentMethodState> upfrontMethods;
  final Map<String, LNDPaymentMethodState> subscriptionMethods;

  const LNDPaymentMethodConfig({
    required this.upfrontMethods,
    required this.subscriptionMethods,
  });

  static const defaultConfig = LNDPaymentMethodConfig(
    upfrontMethods: {
      'card': LNDPaymentMethodState.visibleEnabled,
      'gcash': LNDPaymentMethodState.visibleEnabled,
      'paymaya': LNDPaymentMethodState.visibleEnabled,
      'grab_pay': LNDPaymentMethodState.visibleEnabled,
      'shopeepay': LNDPaymentMethodState.visibleEnabled,
      'qrph': LNDPaymentMethodState.visibleEnabled,
      'bpi': LNDPaymentMethodState.visibleEnabled,
      'ubp': LNDPaymentMethodState.visibleEnabled,
      'bdo': LNDPaymentMethodState.visibleEnabled,
      'landbank': LNDPaymentMethodState.visibleEnabled,
      'metrobank': LNDPaymentMethodState.visibleEnabled,
    },
    subscriptionMethods: {
      'card': LNDPaymentMethodState.visibleEnabled,
      'paymaya': LNDPaymentMethodState.visibleEnabled,
    },
  );

  factory LNDPaymentMethodConfig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) return defaultConfig;
    final data = snapshot.data() ?? const <String, dynamic>{};
    return LNDPaymentMethodConfig(
      upfrontMethods: _readMethodMap(
        data['upfrontMethods'],
        defaultConfig.upfrontMethods,
      ),
      subscriptionMethods: _readMethodMap(
        data['subscriptionMethods'],
        defaultConfig.subscriptionMethods,
      ),
    );
  }

  LNDPaymentMethodState upfrontState(String id) {
    return upfrontMethods[id] ?? LNDPaymentMethodState.visibleEnabled;
  }

  LNDPaymentMethodState subscriptionState(String id) {
    return subscriptionMethods[id] ?? LNDPaymentMethodState.hiddenDisabled;
  }

  static Map<String, LNDPaymentMethodState> _readMethodMap(
    Object? value,
    Map<String, LNDPaymentMethodState> defaults,
  ) {
    final source =
        value is Map
            ? Map<String, dynamic>.from(value)
            : const <String, dynamic>{};
    return defaults.map((id, fallback) {
      final raw = source[id];
      final map = raw is Map ? Map<String, dynamic>.from(raw) : null;
      return MapEntry(
        id,
        LNDPaymentMethodState(
          visible:
              map?['visible'] is bool
                  ? map!['visible'] as bool
                  : fallback.visible,
          enabled:
              map?['enabled'] is bool
                  ? map!['enabled'] as bool
                  : fallback.enabled,
        ),
      );
    });
  }
}

class LNDPaymentMethodState {
  final bool visible;
  final bool enabled;

  const LNDPaymentMethodState({required this.visible, required this.enabled});

  static const visibleEnabled = LNDPaymentMethodState(
    visible: true,
    enabled: true,
  );

  static const hiddenDisabled = LNDPaymentMethodState(
    visible: false,
    enabled: false,
  );
}
