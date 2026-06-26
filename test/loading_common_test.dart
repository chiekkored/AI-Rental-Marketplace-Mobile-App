import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/controllers/loading/loading.controller.dart';
import 'package:lend/presentation/pages/loading_overlay/loading_overlay.page.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('LNDLoading show and hide update visibility and text', () {
    final controller = Get.put(LoadingController());

    LNDLoading.show(text: 'Processing payment...');

    expect(controller.isLoading.value, isTrue);
    expect(controller.text.value, 'Processing payment...');

    LNDLoading.hide();

    expect(controller.isLoading.value, isFalse);
    expect(controller.text.value, isNull);
  });

  test('LNDLoading show supports null text', () {
    final controller = Get.put(LoadingController());

    LNDLoading.show();

    expect(controller.isLoading.value, isTrue);
    expect(controller.text.value, isNull);
  });

  testWidgets('LoadingOverlay renders optional loading text', (tester) async {
    final controller = Get.put(LoadingController());
    controller.show(text: 'Waiting for PayMongo confirmation...');

    await tester.pumpWidget(
      MaterialApp(
        theme: LNDAppTheme.light,
        home: const LoadingOverlay(child: SizedBox.shrink()),
      ),
    );

    expect(find.text('Waiting for PayMongo confirmation...'), findsOneWidget);
  });
}
