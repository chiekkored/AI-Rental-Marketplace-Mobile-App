import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

void main() {
  testWidgets('LNDText uses themed text color by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LNDAppTheme.light,
        home: LNDText.regular(text: 'Hello'),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.text.style?.color, LNDTheme.light.textPrimary);
  });

  testWidgets('LNDButton primary uses themed primary by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LNDAppTheme.light,
        home: LNDButton.primary(
          text: 'Continue',
          enabled: true,
          onPressed: () {},
        ),
      ),
    );

    final outlinedButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    final backgroundColor = outlinedButton.style?.backgroundColor?.resolve({
      WidgetState.focused,
    });

    expect(backgroundColor, LNDTheme.light.primary);
  });

  testWidgets('LNDTextField uses themed input decoration colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LNDAppTheme.light,
        home: Scaffold(
          body: LNDTextField.regular(
            controller: TextEditingController(),
            hintText: 'Email',
          ),
        ),
      ),
    );

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.fillColor, LNDTheme.light.surfaceMuted);
    expect(
      (inputDecorator.decoration.focusedBorder as OutlineInputBorder)
          .borderSide
          .color,
      LNDTheme.light.primary,
    );
  });
}
