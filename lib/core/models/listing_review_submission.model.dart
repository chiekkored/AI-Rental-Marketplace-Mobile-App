import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/core/models/simple_user.model.dart';

class ListingReviewSubmission {
  final String id;
  final String? assetId;
  final String ownerId;
  final String submissionType;
  final String status;
  final ListingReviewDraft listing;
  final ListingAiReview? aiReview;
  final Timestamp? submittedAt;
  final Timestamp? reviewedAt;

  const ListingReviewSubmission({
    required this.id,
    required this.assetId,
    required this.ownerId,
    required this.submissionType,
    required this.status,
    required this.listing,
    required this.aiReview,
    required this.submittedAt,
    required this.reviewedAt,
  });

  bool get isRejected => status == 'Rejected';

  Asset toEditableAsset({SimpleUserModel? owner}) {
    return Asset(
      id: assetId ?? listing.id ?? id,
      ownerId: ownerId,
      owner: owner,
      title: listing.title,
      description: listing.description,
      categoryId: listing.categoryId,
      categoryName: listing.categoryName,
      subcategoryId: listing.subcategoryId,
      subcategoryName: listing.subcategoryName,
      rates: listing.rates,
      location: listing.location,
      images: listing.images,
      showcase: listing.showcase,
      inclusions: listing.inclusions,
      ownerInstructions: listing.ownerInstructions,
      blocksEndDate: listing.blocksEndDate,
      status: listing.status,
      securityDeposit: listing.securityDeposit,
    );
  }

  factory ListingReviewSubmission.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? <String, dynamic>{};
    return ListingReviewSubmission(
      id: map['id']?.toString() ?? doc.id,
      assetId: map['assetId']?.toString(),
      ownerId: map['ownerId']?.toString() ?? '',
      submissionType: map['submissionType']?.toString() ?? 'create',
      status: map['status']?.toString() ?? '',
      listing: ListingReviewDraft.fromMap(
        Map<String, dynamic>.from(map['listing'] as Map? ?? {}),
      ),
      aiReview:
          map['aiReview'] is Map
              ? ListingAiReview.fromMap(
                Map<String, dynamic>.from(map['aiReview'] as Map),
              )
              : null,
      submittedAt: map['submittedAt'] is Timestamp ? map['submittedAt'] : null,
      reviewedAt: map['reviewedAt'] is Timestamp ? map['reviewedAt'] : null,
    );
  }
}

class ListingReviewDraft {
  final String? id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final Rates rates;
  final Location? location;
  final List<String> images;
  final List<String> showcase;
  final List<String> inclusions;
  final String? ownerInstructions;
  final bool blocksEndDate;
  final String status;
  final SecurityDeposit securityDeposit;

  const ListingReviewDraft({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.rates,
    required this.location,
    required this.images,
    required this.showcase,
    required this.inclusions,
    required this.ownerInstructions,
    required this.blocksEndDate,
    required this.status,
    required this.securityDeposit,
  });

  factory ListingReviewDraft.fromMap(Map<String, dynamic> map) {
    return ListingReviewDraft(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      subcategoryId: map['subcategoryId']?.toString(),
      subcategoryName: map['subcategoryName']?.toString(),
      rates:
          map['rates'] is Map
              ? Rates.fromMap(Map<String, dynamic>.from(map['rates'] as Map))
              : Rates(daily: 0),
      location:
          map['location'] is Map
              ? Location.fromMap(
                Map<String, dynamic>.from(map['location'] as Map),
              )
              : null,
      images: _stringList(map['images']),
      showcase: _stringList(map['showcase']),
      inclusions: _stringList(map['inclusions']),
      ownerInstructions: map['ownerInstructions']?.toString(),
      blocksEndDate: map['blocksEndDate'] == true,
      status: map['status']?.toString() ?? 'Available',
      securityDeposit:
          map['securityDeposit'] is Map
              ? SecurityDeposit.fromMap(
                Map<String, dynamic>.from(map['securityDeposit'] as Map),
              )
              : const SecurityDeposit.disabled(),
    );
  }
}

class ListingAiReview {
  final String decision;
  final String severity;
  final List<String> categories;
  final List<String> reasons;
  final String? safeTitleSuggestion;
  final String? safeDescriptionSuggestion;

  const ListingAiReview({
    required this.decision,
    required this.severity,
    required this.categories,
    required this.reasons,
    required this.safeTitleSuggestion,
    required this.safeDescriptionSuggestion,
  });

  factory ListingAiReview.fromMap(Map<String, dynamic> map) {
    return ListingAiReview(
      decision: map['decision']?.toString() ?? '',
      severity: map['severity']?.toString() ?? '',
      categories: _stringList(map['categories']),
      reasons: _stringList(map['reasons']),
      safeTitleSuggestion: map['safeTitleSuggestion']?.toString(),
      safeDescriptionSuggestion: map['safeDescriptionSuggestion']?.toString(),
    );
  }
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}
