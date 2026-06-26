import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('horizontal menu bottom sheet renders scrollable icon tiles', (
    tester,
  ) async {
    late Future<String?> resultFuture;
    String? tappedValue;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: Scaffold(
          body: Builder(
            builder:
                (_) => TextButton(
                  onPressed: () {
                    resultFuture = LNDShow.menuBottomSheetHorizontal<String>(
                      items: [
                        LNDMenuItem(
                          label: 'Generate QR',
                          value: 'qr',
                          icon: Icons.qr_code_2_rounded,
                          onTap: (value) => tappedValue = value,
                        ),
                        LNDMenuItem(
                          label: 'Update Listing',
                          value: 'update',
                          icon: Icons.edit_outlined,
                          onTap: (value) => tappedValue = value,
                        ),
                        LNDMenuItem(
                          label: 'Delete Listing',
                          value: 'delete',
                          icon: Icons.delete_outline_rounded,
                          isDestructive: true,
                          onTap: (value) => tappedValue = value,
                        ),
                      ],
                    );
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Generate QR'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
    expect(find.text('Update Listing'), findsOneWidget);
    expect(find.text('Delete Listing'), findsOneWidget);

    final deleteIcon = tester.widget<Icon>(
      find.byIcon(Icons.delete_outline_rounded),
    );
    expect(deleteIcon.color, LNDTheme.light.danger);

    await tester.tap(find.text('Generate QR'));
    await tester.pumpAndSettle();

    expect(tappedValue, 'qr');
    expect(await resultFuture, 'qr');
  });
}
