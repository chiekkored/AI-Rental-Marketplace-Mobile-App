import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/presentation/controllers/blocked_users/blocked_users.controller.dart';
import 'package:lend/presentation/pages/blocked_users/blocked_users.page.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.testMode = false;
  });

  testWidgets('renders long blocked user rows without ListTile overflow', (
    tester,
  ) async {
    Get.put<BlockedUsersController>(
      _TestBlockedUsersController([
        SimpleUserModel(
          uid: 'blocked-1',
          firstName: 'Alexandria Cassandra Penelope',
          lastName: 'Montgomery-Worthington-Smythe',
        ),
      ]),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: LNDAppTheme.light, home: const BlockedUsersPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unblock'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestBlockedUsersController extends BlockedUsersController {
  _TestBlockedUsersController(List<SimpleUserModel> seedUsers)
    : _seedUsers = seedUsers.obs;

  final RxList<SimpleUserModel> _seedUsers;
  final RxBool _loading = false.obs;

  @override
  List<SimpleUserModel> get users => _seedUsers;

  @override
  bool get isLoading => _loading.value;

  @override
  void onReady() {}

  @override
  Future<void> unblock(SimpleUserModel user) async {}

  @override
  void onClose() {
    _seedUsers.close();
    _loading.close();
    super.onClose();
  }
}
