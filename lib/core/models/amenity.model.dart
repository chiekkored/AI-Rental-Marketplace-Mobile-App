import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  final String id;
  final String label;
  final String iconKey;
  final String group;
  final int sortOrder;
  final bool isActive;
  final List<String> appliesToDetailSchemaKeys;

  const Amenity({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.group,
    required this.sortOrder,
    required this.isActive,
    required this.appliesToDetailSchemaKeys,
  });

  factory Amenity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Amenity.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Amenity.fromMap(Map<String, dynamic> map, {String? id}) {
    return Amenity(
      id: id ?? map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      iconKey: map['iconKey']?.toString() ?? 'default',
      group: map['group']?.toString() ?? 'General',
      sortOrder: _intValue(map['sortOrder']),
      isActive: map['isActive'] == true,
      appliesToDetailSchemaKeys: _stringList(map['appliesToDetailSchemaKeys']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'iconKey': iconKey,
      'group': group,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'appliesToDetailSchemaKeys': appliesToDetailSchemaKeys,
    };
  }

  bool appliesToDetailSchemaKey(String detailSchemaKey) {
    return appliesToDetailSchemaKeys.contains(detailSchemaKey);
  }

  static int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    final items =
        value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList();
    items.sort();
    return items;
  }
}
