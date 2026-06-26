class LNDNotificationPreferences {
  final bool pushEnabled;
  final bool messagesPushEnabled;
  final bool bookingsPushEnabled;
  final bool paymentsPushEnabled;
  final bool listingsPushEnabled;
  final bool verificationPushEnabled;
  final bool bookingEmailsEnabled;
  final bool paymentEmailsEnabled;

  const LNDNotificationPreferences({
    this.pushEnabled = true,
    this.messagesPushEnabled = true,
    this.bookingsPushEnabled = true,
    this.paymentsPushEnabled = true,
    this.listingsPushEnabled = true,
    this.verificationPushEnabled = true,
    this.bookingEmailsEnabled = true,
    this.paymentEmailsEnabled = true,
  });

  factory LNDNotificationPreferences.fromMap(Map<String, dynamic>? map) {
    final channels = _nestedMap(map, 'channels');
    final pushCategories = _nestedMap(map, 'pushCategories');
    final emailCategories = _nestedMap(map, 'emailCategories');

    return LNDNotificationPreferences(
      pushEnabled: _boolOrDefault(channels['push'], true),
      messagesPushEnabled: _boolOrDefault(pushCategories['messages'], true),
      bookingsPushEnabled: _boolOrDefault(pushCategories['bookings'], true),
      paymentsPushEnabled: _boolOrDefault(pushCategories['payments'], true),
      listingsPushEnabled: _boolOrDefault(pushCategories['listings'], true),
      verificationPushEnabled: _boolOrDefault(
        pushCategories['verification'],
        true,
      ),
      bookingEmailsEnabled: _boolOrDefault(emailCategories['bookings'], true),
      paymentEmailsEnabled: _boolOrDefault(emailCategories['payments'], true),
    );
  }

  LNDNotificationPreferences copyWith({
    bool? pushEnabled,
    bool? messagesPushEnabled,
    bool? bookingsPushEnabled,
    bool? paymentsPushEnabled,
    bool? listingsPushEnabled,
    bool? verificationPushEnabled,
    bool? bookingEmailsEnabled,
    bool? paymentEmailsEnabled,
  }) {
    return LNDNotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      messagesPushEnabled: messagesPushEnabled ?? this.messagesPushEnabled,
      bookingsPushEnabled: bookingsPushEnabled ?? this.bookingsPushEnabled,
      paymentsPushEnabled: paymentsPushEnabled ?? this.paymentsPushEnabled,
      listingsPushEnabled: listingsPushEnabled ?? this.listingsPushEnabled,
      verificationPushEnabled:
          verificationPushEnabled ?? this.verificationPushEnabled,
      bookingEmailsEnabled: bookingEmailsEnabled ?? this.bookingEmailsEnabled,
      paymentEmailsEnabled: paymentEmailsEnabled ?? this.paymentEmailsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channels': {'push': pushEnabled},
      'pushCategories': {
        'messages': messagesPushEnabled,
        'bookings': bookingsPushEnabled,
        'payments': paymentsPushEnabled,
        'listings': listingsPushEnabled,
        'verification': verificationPushEnabled,
      },
      'emailCategories': {
        'bookings': bookingEmailsEnabled,
        'payments': paymentEmailsEnabled,
      },
    };
  }

  static Map<String, dynamic> _nestedMap(
    Map<String, dynamic>? map,
    String key,
  ) {
    final value = map?[key];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  static bool _boolOrDefault(dynamic value, bool defaultValue) {
    return value is bool ? value : defaultValue;
  }
}
