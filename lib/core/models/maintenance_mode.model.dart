import 'package:cloud_firestore/cloud_firestore.dart';

class LNDMaintenanceMode {
  final bool enabled;
  final Timestamp? updatedAt;
  final String? updatedBy;

  const LNDMaintenanceMode({
    required this.enabled,
    this.updatedAt,
    this.updatedBy,
  });

  static const disabled = LNDMaintenanceMode(enabled: false);

  factory LNDMaintenanceMode.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return LNDMaintenanceMode.fromMap(doc.data() ?? <String, dynamic>{});
  }

  factory LNDMaintenanceMode.fromMap(Map<String, dynamic> map) {
    return LNDMaintenanceMode(
      enabled: map['enabled'] == true,
      updatedAt: _timestampValue(map['updatedAt']),
      updatedBy: _nullableString(map['updatedBy']),
    );
  }

  static Timestamp? _timestampValue(dynamic value) {
    if (value is Timestamp) return value;
    if (value is Map && value['_seconds'] is int) {
      return Timestamp(
        value['_seconds'] as int,
        value['_nanoseconds'] as int? ?? 0,
      );
    }
    return null;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
