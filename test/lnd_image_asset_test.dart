import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/common/images.common.dart';

void main() {
  testWidgets('LNDImage renders bundled asset paths', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LNDImage.custom(
            imageUrl: 'assets/images/payment/gcash.png',
            height: 24.0,
            width: 40.0,
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
