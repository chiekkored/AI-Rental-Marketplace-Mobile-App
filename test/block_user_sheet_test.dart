import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/pages/chat_information/widgets/block_user_sheet.widget.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.testMode = false;
  });

  testWidgets('shows current-booking coordination messages', (tester) async {
    await _pumpSheet(tester, requiresCoordination: true.obs);

    expect(
      find.text(
        'Your current booking and chat will stay available until the booking is resolved.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'After it is resolved, you won’t be able to contact each other.',
      ),
      findsOneWidget,
    );
    expect(find.text('This chat will be archived.'), findsNothing);
  });

  testWidgets('shows terminal-booking messages', (tester) async {
    await _pumpSheet(tester, requiresCoordination: false.obs);

    expect(
      find.text('You won’t be able to contact each other.'),
      findsOneWidget,
    );
    expect(find.text('This chat will be archived.'), findsOneWidget);
    expect(
      find.text(
        'Your current booking and chat will stay available until the booking is resolved.',
      ),
      findsNothing,
    );
  });

  testWidgets('updates messages when booking coordination changes', (
    tester,
  ) async {
    final requiresCoordination = true.obs;
    await _pumpSheet(tester, requiresCoordination: requiresCoordination);

    expect(find.text('This chat will be archived.'), findsNothing);

    requiresCoordination.value = false;
    await tester.pump();

    expect(find.text('This chat will be archived.'), findsOneWidget);
  });

  testWidgets('report text button returns report action', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    final requiresCoordination = false.obs;
    final result = Get.bottomSheet<BlockUserSheetAction>(
      BlockUserSheet(
        displayName: 'Alex Rentals',
        bookingRequiresCoordination: () => requiresCoordination.value,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report user'));
    await tester.pumpAndSettle();

    expect(await result, BlockUserSheetAction.report);
  });
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required RxBool requiresCoordination,
}) {
  return tester.pumpWidget(
    GetMaterialApp(
      theme: LNDAppTheme.light,
      home: Scaffold(
        body: BlockUserSheet(
          displayName: 'Alex Rentals',
          bookingRequiresCoordination: () => requiresCoordination.value,
        ),
      ),
    ),
  );
}
