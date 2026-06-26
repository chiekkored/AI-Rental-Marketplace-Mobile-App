import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

void main() {
  test('light design system uses orange primary color', () {
    expect(LNDTheme.light.primary, const Color(0xFFFF6B00));
    expect(
      LNDAppTheme.light.extension<LNDTheme>()?.primary,
      LNDTheme.light.primary,
    );
  });

  testWidgets('BuildContext exposes LND theme extension', (tester) async {
    late LNDTheme colors;

    await tester.pumpWidget(
      MaterialApp(
        theme: LNDAppTheme.light,
        home: Builder(
          builder: (context) {
            colors = context.lndTheme;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors.primary, const Color(0xFFFF6B00));
    expect(colors.surface, Colors.white);
  });
}
