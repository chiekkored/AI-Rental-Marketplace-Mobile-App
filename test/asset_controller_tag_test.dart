import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/asset/asset.page.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(ProfileController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  test('tagged asset controllers have independent lifecycles', () async {
    const snapshotTag = 'asset:booking:asset-1:snapshot';
    const liveTag = 'asset:public:asset-1:live';
    final snapshotController = _TestAssetController(
      AssetPageArgs(
        asset: Asset(id: 'asset-1', title: 'Snapshot title'),
        controllerTag: snapshotTag,
        source: AssetPageSource.booking,
      ),
    );
    final liveController = _TestAssetController(
      AssetPageArgs(
        asset: Asset(id: 'asset-1', title: 'Live title'),
        controllerTag: liveTag,
      ),
    );

    Get.put<AssetController>(snapshotController, tag: snapshotTag);
    Get.put<AssetController>(liveController, tag: liveTag);

    expect(Get.find<AssetController>(tag: snapshotTag).isBookingSnapshot, true);
    expect(Get.find<AssetController>(tag: liveTag).isBookingSnapshot, false);
    expect(
      Get.find<AssetController>(tag: snapshotTag).asset?.title,
      'Snapshot title',
    );
    expect(Get.find<AssetController>(tag: liveTag).asset?.title, 'Live title');

    await Get.delete<AssetController>(tag: liveTag);

    expect(Get.isRegistered<AssetController>(tag: liveTag), false);
    expect(Get.isRegistered<AssetController>(tag: snapshotTag), true);
    expect(
      Get.find<AssetController>(tag: snapshotTag).asset?.title,
      'Snapshot title',
    );
  });

  testWidgets('asset navigation pushes another asset route', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const SizedBox.shrink(),
        getPages: [
          GetPage(
            name: AssetPage.routeName,
            page: () {
              final args = Get.arguments as AssetPageArgs;
              return Text(
                '${args.source.name}:${args.asset?.id}:${args.controllerTag}',
                textDirection: TextDirection.ltr,
              );
            },
            preventDuplicates: false,
          ),
        ],
      ),
    );

    LNDNavigate.toAssetPage(
      args: Asset(id: 'asset-1'),
      source: AssetPageSource.booking,
    );
    await tester.pumpAndSettle();
    final snapshotArgs = Get.arguments as AssetPageArgs;

    LNDNavigate.toAssetPage(args: Asset(id: 'asset-1'));
    await tester.pumpAndSettle();
    final liveArgs = Get.arguments as AssetPageArgs;

    expect(Get.currentRoute, AssetPage.routeName);
    expect(snapshotArgs.source, AssetPageSource.booking);
    expect(liveArgs.source, AssetPageSource.public);
    expect(liveArgs.asset?.id, snapshotArgs.asset?.id);
    expect(liveArgs.controllerTag, isNot(snapshotArgs.controllerTag));
    expect(find.textContaining('public:asset-1:'), findsOneWidget);

    Get.back<void>();
    await tester.pumpAndSettle();

    expect(find.textContaining('booking:asset-1:'), findsOneWidget);
  });
}

class _TestAssetController extends AssetController {
  _TestAssetController(super.args);

  @override
  void onReady() {}
}
