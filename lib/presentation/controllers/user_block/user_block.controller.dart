import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/recently_viewed/recently_viewed.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/controllers/search/search.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/constants/functions.constant.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class UserBlockController extends GetxController {
  static UserBlockController get instance => Get.find<UserBlockController>();

  final RxSet<String> _excludedUserIds = <String>{}.obs;
  Set<String> get excludedUserIds => _excludedUserIds;

  final RxSet<String> _blockedUserIds = <String>{}.obs;
  Set<String> get blockedUserIds => _blockedUserIds;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  bool isExcluded(String? uid) =>
      uid != null && uid.isNotEmpty && _excludedUserIds.contains(uid);

  bool hasBlocked(String? uid) =>
      uid != null && uid.isNotEmpty && _blockedUserIds.contains(uid);

  void listenForUser(String uid) {
    _subscription?.cancel();
    unawaited(_refreshBlockedUsers());
    LNDLogger.dNoStack('🟢 Block Subscription Started');
    _subscription = FirebaseFirestore.instance
        .collection(LNDCollections.users.name)
        .doc(uid)
        .collection(LNDCollections.blockExclusions.name)
        .snapshots()
        .listen(
          (snapshot) {
            _excludedUserIds.assignAll(snapshot.docs.map((doc) => doc.id));
            _filterLoadedContent();
          },
          onError:
              (Object error, StackTrace stackTrace) => LNDLogger.e(
                'Error listening to blocked users',
                error: error,
                stackTrace: stackTrace,
              ),
        );
  }

  Future<void> blockUser(String targetUserId) async {
    await _manage(action: 'block', targetUserId: targetUserId);
    _excludedUserIds.add(targetUserId);
    _blockedUserIds.add(targetUserId);
    await _removeRecentlyViewedByOwner(targetUserId);
    _filterLoadedContent();
  }

  Future<void> unblockUser(String targetUserId) async {
    await _manage(action: 'unblock', targetUserId: targetUserId);
    _blockedUserIds.remove(targetUserId);
  }

  Future<List<SimpleUserModel>> getBlockedUsers() async {
    final response = await _manage(action: 'list');
    final users = response['users'];
    if (users is! List) {
      _blockedUserIds.clear();
      return [];
    }
    final blockedUsers = users
        .whereType<Map>()
        .map((user) => SimpleUserModel.fromMap(Map<String, dynamic>.from(user)))
        .toList(growable: false);
    _blockedUserIds.assignAll(
      blockedUsers
          .map((user) => user.uid)
          .whereType<String>()
          .where((uid) => uid.isNotEmpty),
    );
    return blockedUsers;
  }

  Future<void> _refreshBlockedUsers() async {
    try {
      await getBlockedUsers();
    } catch (e, st) {
      LNDLogger.e('Error loading blocked users', error: e, stackTrace: st);
    }
  }

  Future<Map<String, dynamic>> _manage({
    required String action,
    String? targetUserId,
  }) async {
    try {
      final callable = LNDCloudFunctionsService.instance.httpsCallable(
        LNDFunctions.manageUserBlock,
      );
      final response = await callable.call<Map<String, dynamic>>({
        'action': action,
        if (targetUserId != null) 'targetUserId': targetUserId,
      });
      return Map<String, dynamic>.from(response.data);
    } on FirebaseFunctionsException catch (e, st) {
      LNDLogger.e('Error managing blocked user', error: e, stackTrace: st);
      throw e.message ?? 'Unable to update blocked users.';
    } catch (e, st) {
      LNDLogger.e('Error managing blocked user', error: e, stackTrace: st);
      throw 'Unable to update blocked users.';
    }
  }

  Future<void> _removeRecentlyViewedByOwner(String ownerId) async {
    final raw = LNDStorageService.readList(
      LNDStorageConstants.recentlyViewedAssets,
    );
    if (raw == null) return;
    final next = raw
        .whereType<String>()
        .where((item) {
          try {
            return SimpleAsset.fromJson(item).owner?.uid != ownerId;
          } catch (_) {
            return true;
          }
        })
        .toList(growable: false);
    await LNDStorageService.writeList(
      LNDStorageConstants.recentlyViewedAssets,
      next,
    );
  }

  void _filterLoadedContent() {
    if (Get.isRegistered<HomeController>()) {
      HomeController.instance.removeExcludedOwners(_excludedUserIds);
    }
    if (Get.isRegistered<SavedController>()) {
      SavedController.instance.removeExcludedOwners(_excludedUserIds);
    }
    if (Get.isRegistered<AssetSearchController>()) {
      AssetSearchController.instance.removeExcludedOwners(_excludedUserIds);
    }
    if (Get.isRegistered<RecentlyViewedController>()) {
      RecentlyViewedController.instance.loadRecentlyViewedAssets();
    }
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _excludedUserIds.clear();
    _blockedUserIds.clear();
    LNDLogger.dNoStack('🔴 Block subscriptions cancelled');
  }

  @override
  void onClose() {
    clear();
    _excludedUserIds.close();
    _blockedUserIds.close();
    super.onClose();
  }
}
