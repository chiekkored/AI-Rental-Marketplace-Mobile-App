import 'package:cloud_firestore/cloud_firestore.dart';

class LNDCategory {
  final String id;
  final String name;
  final String slug;
  final String iconKey;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final bool isFeatured;
  final String? parentId;
  final String listingKind;
  final String detailSchemaKey;
  final int level;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const LNDCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconKey,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.isFeatured,
    required this.parentId,
    required this.listingKind,
    required this.detailSchemaKey,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isParent => parentId == null || parentId!.trim().isEmpty;
  bool get isSubcategory => !isParent;

  factory LNDCategory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return LNDCategory.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory LNDCategory.fromMap(Map<String, dynamic> map, {String? id}) {
    return LNDCategory(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      iconKey: map['iconKey']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      sortOrder: _intValue(map['sortOrder']),
      isActive: map['isActive'] == true,
      isFeatured: map['isFeatured'] == true,
      parentId: _nullableString(map['parentId']),
      listingKind:
          _nullableString(map['listingKind']) ??
          _fallbackSchemaKey(id ?? map['id']?.toString() ?? map['slug']),
      detailSchemaKey:
          _nullableString(map['detailSchemaKey']) ??
          _fallbackSchemaKey(id ?? map['id']?.toString() ?? map['slug']),
      level: _intValue(map['level'], fallback: 1),
      createdAt: _timestampValue(map['createdAt']),
      updatedAt: _timestampValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'slug': slug,
      'iconKey': iconKey,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'parentId': parentId,
      'listingKind': listingKind,
      'detailSchemaKey': detailSchemaKey,
      'level': level,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
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

  static String _fallbackSchemaKey(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    if (text.contains('stay') ||
        text.contains('house') ||
        text.contains('apartment') ||
        text.contains('condo') ||
        text.contains('room')) {
      return 'stay';
    }
    if (text.contains('space') ||
        text.contains('studio') ||
        text.contains('parking') ||
        text.contains('storage')) {
      return 'space';
    }
    if (text.contains('vehicle') || text.contains('car')) return 'vehicle';
    if (text.contains('tool')) return 'tool';
    if (text.contains('electronic') ||
        text.contains('camera') ||
        text.contains('drone')) {
      return 'electronics';
    }
    if (text.contains('party') || text.contains('event')) {
      return 'party_event';
    }
    if (text.contains('clothing') || text.contains('apparel')) {
      return 'clothing';
    }
    return 'generic_asset';
  }
}
