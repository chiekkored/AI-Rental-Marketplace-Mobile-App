class ListingTimeRange {
  final bool enabled;
  final String startTime;
  final String endTime;

  const ListingTimeRange({
    required this.enabled,
    this.startTime = '',
    this.endTime = '',
  });

  factory ListingTimeRange.fromMap(Map<String, dynamic> map) {
    return ListingTimeRange(
      enabled:
          map['enabled'] == true ||
          map['startTime'] != null ||
          map['endTime'] != null,
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
    );
  }

  static ListingTimeRange? fromMapOrNull(dynamic value) {
    if (value is! Map) return null;
    return ListingTimeRange.fromMap(Map<String, dynamic>.from(value));
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      if (startTime.trim().isNotEmpty) 'startTime': startTime,
      if (endTime.trim().isNotEmpty) 'endTime': endTime,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ListingTimeRange &&
        other.enabled == enabled &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(enabled, startTime, endTime);
}
