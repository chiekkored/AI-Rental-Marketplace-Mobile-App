import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_either/dart_either.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/core/models/user.model.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/presentation/common/account_feedback_sheet.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

/// Service for managing user data with metadata versioning.
///
/// Implements lazy-fetch pattern:
/// - Cache user locally with version number
/// - On display, compare cached version with Firestore version
/// - If versions don't match, fetch fresh data
/// - Scheduled Cloud Function syncs stale denormalized copies nightly
///
/// This provides eventual consistency (24h lag) for cosmetic data
/// while maintaining strong consistency on-demand via lazy-fetch.
class UserService extends GetxService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // Cache key for stored user data
  static const String _userCacheKey = 'user_';

  /// Get user with version checking (lazy-fetch pattern)
  ///
  /// Returns cached user if versions match, otherwise fetches fresh from Firestore.
  /// This ensures strong consistency when displaying user info without constant reads.
  Future<UserModel?> getUserWithVersionCheck(String uid) async {
    try {
      // Check local cache first
      final cachedJson = _storage.read('$_userCacheKey$uid');
      if (cachedJson != null) {
        final cachedUser = UserModel.fromMap(
          cachedJson as Map<String, dynamic>,
        );

        // Fetch ONLY the version from Firestore (minimal read cost)
        final versionSnap = await _firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server));

        if (versionSnap.exists) {
          final currentVersion =
              versionSnap.data()?['userMetadataVersion'] ?? 1;

          // If versions match, use cache (strong consistency + efficiency)
          if (cachedUser.userMetadataVersion == currentVersion) {
            LNDLogger.iNoStack(
              'User $uid: using cached data (version $currentVersion)',
            );
            return cachedUser;
          }

          LNDLogger.iNoStack(
            'User $uid: version mismatch (cached: ${cachedUser.userMetadataVersion}, current: $currentVersion), fetching fresh',
          );
        }
      }

      // Version mismatch or no cache - fetch fresh from Firestore
      return await _fetchUserFromFirestore(uid);
    } catch (e, st) {
      LNDLogger.e('Error getting user $uid: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Fetch user from Firestore and cache locally
  Future<UserModel?> _fetchUserFromFirestore(String uid) async {
    try {
      final snap = await _firestore.collection('users').doc(uid).get();

      if (!snap.exists) {
        LNDLogger.wNoStack('User $uid not found in Firestore');
        return null;
      }

      final user = UserModel.fromMap(snap.data() ?? {});

      // Cache the user locally
      _storage.write('$_userCacheKey$uid', user.toMap());
      LNDLogger.iNoStack(
        'User $uid: cached fresh data (version ${user.userMetadataVersion})',
      );

      return user;
    } catch (e, st) {
      LNDLogger.e(
        'Error fetching user $uid from Firestore: $e',
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Update user profile and increment version number
  ///
  /// This increments the userMetadataVersion so that:
  /// 1. Mobile caches detect staleness via lazy-fetch
  /// 2. Scheduled function knows to sync denormalized copies
  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      // Get current version
      final userSnap = await _firestore.collection('users').doc(uid).get();
      final currentVersion =
          (userSnap.data()?['userMetadataVersion'] ?? 1) as int;

      // Prepare update with incremented version
      final updateData = <String, dynamic>{
        'userMetadataVersion': currentVersion + 1,
      };

      // Only add fields that were provided
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      // Single write to Firestore
      await _firestore.collection('users').doc(uid).update(updateData);

      // Invalidate local cache immediately so next fetch gets fresh data
      clearUserCache(uid);
      LNDLogger.iNoStack(
        'User $uid: profile updated, version incremented to ${currentVersion + 1}',
      );
    } catch (e, st) {
      LNDLogger.e('Error updating user $uid profile: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Get SimpleUser model with version (for denormalized copies)
  ///
  /// Returns lightweight SimpleUser object that includes version number.
  /// This is stored in bookings, chats, etc. for efficient reads.
  Future<SimpleUserModel?> getSimpleUser(String uid) async {
    try {
      final user = await getUserWithVersionCheck(uid);
      if (user == null) return null;

      return SimpleUserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        photoUrl: user.photoUrl,
        verified: user.verified,
        status: user.status,
        isFoundingOwner: user.isFoundingOwnerAccount,
        userMetadataVersion: user.userMetadataVersion,
      );
    } catch (e) {
      LNDLogger.eNoStack('Error getting SimpleUser $uid: $e');
      rethrow;
    }
  }

  /// Clear cache for specific user
  void clearUserCache(String uid) {
    _storage.remove('$_userCacheKey$uid');
    LNDLogger.dNoStack('Cleared cache for user $uid');
  }

  /// Clear all user caches
  void clearAllUserCache() {
    // Remove all keys starting with cache prefix
    final box = _storage.getValues();
    box?.forEach((key, _) {
      if (key.toString().startsWith(_userCacheKey)) {
        _storage.remove(key);
      }
    });
    LNDLogger.dNoStack('Cleared all user caches');
  }

  static Future<Either<LNDAccountDeactivationEligibility, String>>
  getAccountDeactivationEligibility() async {
    try {
      final authId = AuthController.instance.uid;
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.getAccountDeactivationEligibility,
      );

      final result = await callable.call({'uid': authId});
      final data = Map<String, dynamic>.from(result.data);
      return Left(LNDAccountDeactivationEligibility.fromMap(data));
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<LNDAccountDeactivationEligibility, String>>
  getAccountDeletionEligibility() async {
    try {
      final authId = AuthController.instance.uid;
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.getAccountDeletionEligibility,
      );

      final result = await callable.call({'uid': authId});
      final data = Map<String, dynamic>.from(result.data);
      return Left(LNDAccountDeactivationEligibility.fromMap(data));
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<LNDAccountDeactivationResult, String>>
  deactivateAccount({required LNDAccountFeedbackSubmission feedback}) async {
    try {
      final authId = AuthController.instance.uid;

      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.deactivateAccount,
      );

      final result = await callable.call({
        'uid': authId,
        'feedback': feedback.toMap(),
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return Left(LNDAccountDeactivationResult.fromMap(data));
      }

      if (data['blockers'] is List) {
        return Left(LNDAccountDeactivationResult.fromMap(data));
      }

      return Right(data['message'] ?? 'Account deactivation failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<LNDAccountReactivationResult, String>>
  reactivateAccount() async {
    try {
      final authId = AuthController.instance.uid;
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.reactivateAccount,
      );

      final result = await callable.call({'uid': authId});
      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return Left(LNDAccountReactivationResult.fromMap(data));
      }

      return Right(data['message'] ?? 'Account reactivation failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }

  static Future<Either<LNDAccountDeletionResult, String>> deleteAccount({
    required LNDAccountFeedbackSubmission feedback,
  }) async {
    try {
      final authId = AuthController.instance.uid;

      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.deleteUser,
      );

      final result = await callable.call({
        'uid': authId,
        'feedback': feedback.toMap(),
      });

      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true) {
        return Left(LNDAccountDeletionResult.fromMap(data));
      }

      if (data['blockers'] is List) {
        return Left(LNDAccountDeletionResult.fromMap(data));
      }

      return Right(data['message'] ?? 'Account delete failed');
    } on FirebaseFunctionsException catch (e) {
      return Right(e.message ?? 'Something went wrong');
    } catch (e) {
      return Right('Error: $e');
    }
  }
}

class LNDAccountDeactivationEligibility {
  const LNDAccountDeactivationEligibility({
    required this.canDeactivate,
    required this.blockerCount,
    required this.blockers,
  });

  final bool canDeactivate;
  final int blockerCount;
  final List<LNDAccountDeactivationBlockerGroup> blockers;

  factory LNDAccountDeactivationEligibility.fromMap(Map<String, dynamic> map) {
    final rawBlockers = map['blockers'];
    return LNDAccountDeactivationEligibility(
      canDeactivate: map['canDeactivate'] == true,
      blockerCount: (map['blockerCount'] as num?)?.toInt() ?? 0,
      blockers:
          rawBlockers is List
              ? rawBlockers
                  .whereType<Map>()
                  .map(
                    (item) => LNDAccountDeactivationBlockerGroup.fromMap(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList(growable: false)
              : const [],
    );
  }
}

class LNDAccountDeactivationResult {
  const LNDAccountDeactivationResult({
    required this.success,
    required this.eligibility,
    required this.hiddenListingCount,
  });

  final bool success;
  final LNDAccountDeactivationEligibility eligibility;
  final int hiddenListingCount;

  factory LNDAccountDeactivationResult.fromMap(Map<String, dynamic> map) {
    return LNDAccountDeactivationResult(
      success: map['success'] == true,
      eligibility: LNDAccountDeactivationEligibility.fromMap(map),
      hiddenListingCount: (map['hiddenListingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LNDAccountReactivationResult {
  const LNDAccountReactivationResult({required this.restoredListingCount});

  final int restoredListingCount;

  factory LNDAccountReactivationResult.fromMap(Map<String, dynamic> map) {
    return LNDAccountReactivationResult(
      restoredListingCount: (map['restoredListingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LNDAccountDeletionResult {
  const LNDAccountDeletionResult({
    required this.success,
    required this.eligibility,
    required this.deletedListingCount,
    required this.updatedChatCount,
    required this.removedMirrorCount,
  });

  final bool success;
  final LNDAccountDeactivationEligibility eligibility;
  final int deletedListingCount;
  final int updatedChatCount;
  final int removedMirrorCount;

  factory LNDAccountDeletionResult.fromMap(Map<String, dynamic> map) {
    return LNDAccountDeletionResult(
      success: map['success'] == true,
      eligibility: LNDAccountDeactivationEligibility.fromMap(map),
      deletedListingCount: (map['deletedListingCount'] as num?)?.toInt() ?? 0,
      updatedChatCount: (map['updatedChatCount'] as num?)?.toInt() ?? 0,
      removedMirrorCount: (map['removedMirrorCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LNDAccountDeactivationBlockerGroup {
  const LNDAccountDeactivationBlockerGroup({
    required this.key,
    required this.count,
    required this.items,
  });

  final String key;
  final int count;
  final List<LNDAccountDeactivationBlockerItem> items;

  String get title {
    return switch (key) {
      'activeBookings' => 'Pending or active bookings',
      'paymentCheckouts' => 'Pending payment checkouts',
      'moneyMovements' => 'Pending payouts or refunds',
      'outstandingBalances' => 'Outstanding balances',
      'disputes' => 'Unresolved disputes',
      'reports' => 'Open reports',
      'listingReviews' => 'Pending listing reviews',
      'pendingReviews' => 'Pending account reviews',
      _ => 'Pending obligations',
    };
  }

  factory LNDAccountDeactivationBlockerGroup.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    return LNDAccountDeactivationBlockerGroup(
      key: map['key']?.toString() ?? '',
      count: (map['count'] as num?)?.toInt() ?? 0,
      items:
          rawItems is List
              ? rawItems
                  .whereType<Map>()
                  .map(
                    (item) => LNDAccountDeactivationBlockerItem.fromMap(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList(growable: false)
              : const [],
    );
  }
}

class LNDAccountDeactivationBlockerItem {
  const LNDAccountDeactivationBlockerItem({
    required this.id,
    required this.title,
    required this.status,
    required this.type,
  });

  final String? id;
  final String title;
  final String? status;
  final String type;

  factory LNDAccountDeactivationBlockerItem.fromMap(Map<String, dynamic> map) {
    final title =
        map['assetTitle']?.toString() ??
        map['title']?.toString() ??
        map['type']?.toString() ??
        map['id']?.toString() ??
        'Pending item';
    return LNDAccountDeactivationBlockerItem(
      id: map['id']?.toString(),
      title: title,
      status: map['status']?.toString(),
      type: map['type']?.toString() ?? 'Pending obligation',
    );
  }
}
