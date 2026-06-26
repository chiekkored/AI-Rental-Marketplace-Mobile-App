import 'package:get/get.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class BlockedUsersController extends GetxController {
  final RxList<SimpleUserModel> _users = <SimpleUserModel>[].obs;
  List<SimpleUserModel> get users => _users;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onReady() {
    getBlockedUsers();
    super.onReady();
  }

  Future<void> getBlockedUsers() async {
    try {
      _isLoading.value = true;
      _users.assignAll(await UserBlockController.instance.getBlockedUsers());
    } catch (e, st) {
      LNDLogger.e('Error loading blocked users', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load blocked users.');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unblock(SimpleUserModel user) async {
    final uid = user.uid;
    if (uid == null || uid.isEmpty) return;
    final confirmed = await LNDShow.alertDialog<bool>(
      title: 'Unblock this user?',
      content:
          'They may appear in your feeds and search again. Removed saved and recently viewed listings will not be restored.',
      confirmText: 'Unblock',
    );
    if (confirmed != true) return;

    try {
      LNDLoading.show();
      await UserBlockController.instance.unblockUser(uid);
      _users.removeWhere((item) => item.uid == uid);
      LNDLoading.hide();
      LNDSnackbar.showSuccess('User unblocked.');
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error unblocking user', error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to unblock this user.');
    }
  }

  @override
  void onClose() {
    _users.close();
    _isLoading.close();
    super.onClose();
  }
}
