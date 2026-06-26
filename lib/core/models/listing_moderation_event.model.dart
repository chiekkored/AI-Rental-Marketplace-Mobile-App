import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/asset.model.dart';

class ListingModerationEvent {
  final String id;
  final String action;
  final String assetId;
  final Timestamp? createdAt;
  final Asset listing;
  final String reason;

  const ListingModerationEvent({
    required this.id,
    required this.action,
    required this.assetId,
    required this.createdAt,
    required this.listing,
    required this.reason,
  });

  factory ListingModerationEvent.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? <String, dynamic>{};
    final listingMap =
        map['listingSnapshot'] is Map
            ? Map<String, dynamic>.from(map['listingSnapshot'] as Map)
            : <String, dynamic>{};
    final assetId = map['assetId']?.toString() ?? listingMap['id']?.toString();

    listingMap['id'] = assetId ?? doc.id;

    return ListingModerationEvent(
      id: doc.id,
      action: map['action']?.toString() ?? '',
      assetId: assetId ?? '',
      createdAt: map['createdAt'] is Timestamp ? map['createdAt'] : null,
      listing: Asset.fromMap(listingMap),
      reason: map['reason']?.toString() ?? '',
    );
  }
}
