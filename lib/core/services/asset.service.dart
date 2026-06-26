import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/your_listing/your_listing.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class ListingReviewResult {
  final bool accepted;
  final String status;
  final String? decision;
  final String? assetId;
  final String? submissionId;
  final List<String> categories;
  final List<String> reasons;
  final String? safeTitleSuggestion;
  final String? safeDescriptionSuggestion;

  const ListingReviewResult({
    required this.accepted,
    required this.status,
    this.decision,
    this.assetId,
    this.submissionId,
    this.categories = const [],
    this.reasons = const [],
    this.safeTitleSuggestion,
    this.safeDescriptionSuggestion,
  });

  factory ListingReviewResult.fromMap(Map<String, dynamic> map) {
    return ListingReviewResult(
      accepted: map['accepted'] == true,
      status: map['status']?.toString() ?? '',
      decision: map['decision']?.toString(),
      assetId: map['assetId']?.toString(),
      submissionId: map['submissionId']?.toString(),
      categories:
          (map['categories'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      reasons:
          (map['reasons'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
      safeTitleSuggestion: map['safeTitleSuggestion']?.toString(),
      safeDescriptionSuggestion: map['safeDescriptionSuggestion']?.toString(),
    );
  }
}

class CreateDummyListingsResult {
  final bool created;
  final int count;
  final List<String> assetIds;

  const CreateDummyListingsResult({
    required this.created,
    required this.count,
    required this.assetIds,
  });

  factory CreateDummyListingsResult.fromMap(Map<String, dynamic> map) {
    return CreateDummyListingsResult(
      created: map['created'] == true,
      count: int.tryParse(map['count']?.toString() ?? '') ?? 0,
      assetIds:
          (map['assetIds'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
    );
  }
}

class ListingDeletionBookingSummary {
  final String? bookingId;
  final String? renterId;
  final String? renterName;
  final String? status;

  const ListingDeletionBookingSummary({
    required this.bookingId,
    required this.renterId,
    required this.renterName,
    required this.status,
  });

  factory ListingDeletionBookingSummary.fromMap(Map<String, dynamic> map) {
    return ListingDeletionBookingSummary(
      bookingId: map['bookingId']?.toString(),
      renterId: map['renterId']?.toString(),
      renterName: map['renterName']?.toString(),
      status: map['status']?.toString(),
    );
  }
}

class ListingDeletionEligibility {
  final bool canDelete;
  final int blockingBookingCount;
  final List<ListingDeletionBookingSummary> blockingBookings;

  const ListingDeletionEligibility({
    required this.canDelete,
    required this.blockingBookingCount,
    required this.blockingBookings,
  });

  factory ListingDeletionEligibility.fromMap(Map<String, dynamic> map) {
    final bookings = map['blockingBookings'];
    return ListingDeletionEligibility(
      canDelete: map['canDelete'] == true,
      blockingBookingCount:
          int.tryParse(map['blockingBookingCount']?.toString() ?? '') ?? 0,
      blockingBookings:
          bookings is List
              ? bookings
                  .whereType<Map>()
                  .map(
                    (item) => ListingDeletionBookingSummary.fromMap(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList()
              : const [],
    );
  }
}

class LNDAssetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _assetsCollection =
      _firestore.collection(LNDCollections.assets.name);
  static const double nearbyRadiusInKm = 25;

  static String createAssetId() {
    return _assetsCollection.doc().id;
  }

  static String createListingDeactivationRequestId() {
    return _firestore.collection('listingDeactivationRequests').doc().id;
  }

  static Future<ListingReviewResult> submitListingForReview({
    required AddAsset asset,
    required bool isUpdate,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.submitListingForReview,
      );
      final response = await callable.call<Map<String, dynamic>>({
        'submissionType': isUpdate ? 'update' : 'create',
        'assetId': asset.id,
        'ownerId': asset.ownerId,
        'listing': _toListingReviewPayload(asset),
      });
      final result = ListingReviewResult.fromMap(
        Map<String, dynamic>.from(response.data),
      );

      return result;
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error submitting listing for review: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Failed to submit listing.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e(
        'Error submitting listing for review: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to submit listing. Please try again.');
      rethrow;
    }
  }

  static Future<void> createAsset(AddAsset asset) async {
    await submitListingForReview(asset: asset, isUpdate: false);
  }

  static Future<void> createAssets(List<AddAsset> assets) async {
    if (assets.isEmpty) return;
    for (final asset in assets) {
      await submitListingForReview(asset: asset, isUpdate: false);
    }
  }

  static Future<CreateDummyListingsResult> createDummyListings() async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.createDummyListings,
      );
      final response = await callable.call<Map<String, dynamic>>(
        <String, dynamic>{},
      );

      return CreateDummyListingsResult.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error creating dummy listings: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Failed to create dummy listings.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e(
        'Error creating dummy listings: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to create dummy listings.');
      rethrow;
    }
  }

  static Future<void> updateAsset(String assetId, AddAsset asset) async {
    asset.id = assetId;
    await submitListingForReview(asset: asset, isUpdate: true);
  }

  static Future<void> deleteListingReviewSubmission(String submissionId) async {
    try {
      await LNDCloudFunctionsService.instance
          .httpsCallable(LNDFunctions.deleteListingReviewSubmission)
          .call({'submissionId': submissionId});
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error deleting listing review submission: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Failed to delete listing review.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e(
        'Error deleting listing review submission: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Failed to delete listing review.');
      rethrow;
    }
  }

  static Map<String, dynamic> _toListingReviewPayload(AddAsset asset) {
    return <String, dynamic>{
      'id': asset.id,
      'ownerId': asset.ownerId,
      'owner': asset.owner?.toMap(),
      'title': asset.title,
      'description': asset.description,
      'categoryId': asset.categoryId,
      'categoryName': asset.categoryName,
      'subcategoryId': asset.subcategoryId,
      'subcategoryName': asset.subcategoryName,
      ...asset.listingDetails.toMap(),
      'rates': asset.rates.toMap(),
      'location': asset.location?.toMap(),
      'images': asset.images,
      'showcase': asset.showcase,
      'inclusions': asset.inclusions,
      'ownerInstructions': asset.ownerInstructions,
      'blocksEndDate': asset.blocksEndDate,
      'status': asset.status,
      'isDeleted': asset.isDeleted,
      'securityDeposit': asset.securityDeposit.toMap(),
    };
  }

  static Future<ListingDeletionEligibility> getListingDeletionEligibility({
    required String assetId,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.getListingDeletionEligibility,
      );
      final response = await callable.call<Map<String, dynamic>>({
        'assetId': assetId,
      });
      return ListingDeletionEligibility.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error checking listing deletion eligibility: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Unable to check listing.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e(
        'Error checking listing deletion eligibility: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to check listing.');
      rethrow;
    }
  }

  static Future<void> deleteAsset(String assetId, String ownerId) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.deleteListing,
      );
      await callable.call({'assetId': assetId});

      HomeController.instance.removeLocalAsset(assetId);
      YourListingController.instance.removeLocalAsset(
        assetId,
      ); // Also remove from YourListingController

      LNDSnackbar.showSuccess('Asset deleted successfully!');
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error deleting asset: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Failed to delete asset.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e('Error deleting asset: $e', error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to delete asset. Please try again.');
      rethrow;
    }
  }

  static Future<void> requestListingDeactivationReview({
    required String assetId,
    required List<String> evidenceUrls,
    required String notes,
    required String reason,
    required String requestId,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.requestListingDeactivationReview,
      );
      await callable.call({
        'assetId': assetId,
        'evidenceUrls': evidenceUrls,
        'notes': notes,
        'reason': reason,
        'requestId': requestId,
      });

      YourListingController.instance.refreshMyAssets();
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e(
        'Error requesting listing deactivation: ${e.message}',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError(e.message ?? 'Unable to request review.');
      rethrow;
    } catch (e, st) {
      LNDLogger.e(
        'Error requesting listing deactivation: $e',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to request review.');
      rethrow;
    }
  }

  static Future<void> updateAssetAvailability({
    required String assetId,
    required String ownerId,
    required String availability,
  }) async {
    try {
      final batch = _firestore.batch();
      final assetDoc = _firestore
          .collection(LNDCollections.assets.name)
          .doc(assetId);
      final userAssetDoc = _firestore
          .collection(LNDCollections.users.name)
          .doc(ownerId)
          .collection(LNDCollections.assets.name)
          .doc(assetId);

      batch.update(assetDoc, {'status': availability});
      batch.update(userAssetDoc, {'status': availability});

      await batch.commit();

      YourListingController.instance.refreshMyAssets();
    } catch (e, st) {
      LNDLogger.e(
        'Error updating asset availability: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Fetches a list of assets, with an optional category filter.
  static Future<List<Asset>> getAssets({String? categoryId}) async {
    try {
      Query query = _assetsCollection
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: Availability.available.label);

      if (categoryId?.trim().isNotEmpty == true) {
        query = query.where('categoryId', isEqualTo: categoryId!.trim());
      }

      final result = await query.get();
      return result.docs
          .map((doc) => Asset.fromMap(doc.data() as Map<String, dynamic>))
          .where((asset) => !_isBlockedOwner(asset.ownerId))
          .toList();
    } catch (e, st) {
      LNDLogger.e('Error getting assets: $e', error: e, stackTrace: st);
      return [];
    }
  }

  /// Fetches a paginated list of assets with cursor-based pagination.
  /// [limit] determines how many assets to fetch per page.
  /// [lastDocument] is used for cursor-based pagination (omit for first page).
  /// Returns a map with 'assets' and 'lastDocument' keys.
  static Future<({List<Asset> assets, DocumentSnapshot? lastDocument})>
  getAssetsPaginated({
    required int limit,
    String? categoryId,
    Location? location,
    String? currencyCode,
    DocumentSnapshot? lastDocument,
    String? excludeOwnerId,
  }) async {
    try {
      Query query = _assetsCollection
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: Availability.available.label);

      if (location?.country?.trim().isNotEmpty == true) {
        query = query.where('location.country', isEqualTo: location!.country);
      }

      if (currencyCode?.trim().isNotEmpty == true) {
        query = query.where('rates.currency', isEqualTo: currencyCode!.trim());
      }

      if (location?.locality?.trim().isNotEmpty == true) {
        query = query.where('location.locality', isEqualTo: location!.locality);
      }

      if (categoryId?.trim().isNotEmpty == true) {
        query = query.where('categoryId', isEqualTo: categoryId!.trim());
      }

      // Order by createdAt to maintain consistent pagination
      query = query.orderBy('createdAt', descending: true);

      // Use previous last document for cursor-based pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Add limit
      query = query.limit(limit);

      final result = await query.get();

      if (result.docs.isEmpty) {
        return (assets: <Asset>[], lastDocument: null);
      }

      final assets =
          result.docs
              .map((doc) => Asset.fromMap(doc.data() as Map<String, dynamic>))
              .where((asset) => !_isExcludedOwner(asset, excludeOwnerId))
              .where((asset) => !_isBlockedOwner(asset.ownerId))
              .where((asset) => _matchesCurrency(asset, currencyCode))
              .toList();

      return (
        assets: assets,
        lastDocument: result.docs.isNotEmpty ? result.docs.last : null,
      );
    } catch (e, st) {
      LNDLogger.e(
        'Error getting paginated assets: $e',
        error: e,
        stackTrace: st,
      );
      return (assets: <Asset>[], lastDocument: null);
    }
  }

  static Future<List<Asset>> getNearbyAssets({
    required Location? location,
    String? categoryId,
    int limit = 36,
    double radiusInKm = nearbyRadiusInKm,
    String? excludeOwnerId,
    String? currencyCode,
  }) async {
    final lat = location?.lat;
    final lng = location?.lng;
    if (lat == null || lng == null) return [];

    try {
      final center = GeoFirePoint(GeoPoint(lat, lng));
      final geoRef = GeoCollectionReference<Map<String, dynamic>>(
        _assetsCollection,
      );
      final snapshots = await geoRef.fetchWithinWithDistance(
        center: center,
        radiusInKm: radiusInKm,
        field: 'location',
        geohashField: 'geohash',
        geopointFrom: (data) {
          final locationData = data['location'];
          if (locationData is! Map) return const GeoPoint(0, 0);
          final parsed = Location.fromMap(
            Map<String, dynamic>.from(locationData),
          );
          return parsed.latLng ?? const GeoPoint(0, 0);
        },
        queryBuilder: (query) {
          var nextQuery = query
              .where('isDeleted', isEqualTo: false)
              .where('status', isEqualTo: Availability.available.label);
          if (categoryId?.trim().isNotEmpty == true) {
            nextQuery = nextQuery.where(
              'categoryId',
              isEqualTo: categoryId!.trim(),
            );
          }
          if (currencyCode?.trim().isNotEmpty == true) {
            nextQuery = nextQuery.where(
              'rates.currency',
              isEqualTo: currencyCode!.trim(),
            );
          }
          return nextQuery;
        },
        strictMode: true,
      );

      final seen = <String>{};
      final assets = <Asset>[];
      for (final snapshot in snapshots) {
        final asset = Asset.fromMap(snapshot.documentSnapshot.data()!);
        if (asset.id.isEmpty || !seen.add(asset.id)) continue;
        if (_isExcludedOwner(asset, excludeOwnerId)) continue;
        if (_isBlockedOwner(asset.ownerId)) continue;
        if (!_matchesCurrency(asset, currencyCode)) continue;
        assets.add(asset);
        if (assets.length >= limit) break;
      }

      return assets;
    } catch (e, st) {
      LNDLogger.e('Error getting nearby assets: $e', error: e, stackTrace: st);
      return [];
    }
  }

  static bool _isExcludedOwner(Asset asset, String? excludeOwnerId) {
    return excludeOwnerId != null && asset.ownerId == excludeOwnerId;
  }

  static bool _matchesCurrency(Asset asset, String? currencyCode) {
    final normalized = currencyCode?.trim();
    if (normalized == null || normalized.isEmpty) return true;
    return asset.rates?.currency?.trim() == normalized;
  }

  static bool _isBlockedOwner(String? ownerId) {
    return Get.isRegistered<UserBlockController>() &&
        UserBlockController.instance.isExcluded(ownerId);
  }

  /// Fetches a single asset by its ID.
  static Future<Asset?> getAssetById(String assetId) async {
    try {
      final result = await _assetsCollection.doc(assetId).get();

      if (!result.exists) {
        return null;
      }

      final assetData = Asset.fromMap(result.data() as Map<String, dynamic>);
      if (assetData.isDeleted) {
        return null; // Don't return deleted assets
      }
      if (_isBlockedOwner(assetData.ownerId)) {
        return null;
      }

      return assetData;
    } catch (e, st) {
      LNDLogger.e('Error getting asset by ID: $e', error: e, stackTrace: st);
      return null;
    }
  }

  /// Fetches the assets for a specific user.
  /// Note: This fetches SimpleAsset because it's typically used for user's own listings
  /// which might not need full Asset details initially.
  static Future<List<SimpleAsset>> getAssetsByUserId(String userId) async {
    try {
      final result =
          await _ownerAssetsCollection(
            userId,
          ).where('isDeleted', isEqualTo: false).get();

      return result.docs.map(_simpleAssetFromDoc).toList();
    } catch (e, st) {
      LNDLogger.e('Error getting user assets: $e', error: e, stackTrace: st);
      return [];
    }
  }

  static Future<List<SimpleAsset>> getOwnerAssets(String userId) {
    return getAssetsByUserId(userId);
  }

  static Stream<List<SimpleAsset>> watchOwnerAssets(String userId) {
    return _ownerAssetsCollection(userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_simpleAssetFromDoc).toList());
  }

  static CollectionReference<Map<String, dynamic>> _ownerAssetsCollection(
    String userId,
  ) {
    return _firestore
        .collection(LNDCollections.users.name)
        .doc(userId)
        .collection(LNDCollections.assets.name);
  }

  static SimpleAsset _simpleAssetFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    data['id'] ??= doc.id;
    return SimpleAsset.fromMap(data);
  }
}
