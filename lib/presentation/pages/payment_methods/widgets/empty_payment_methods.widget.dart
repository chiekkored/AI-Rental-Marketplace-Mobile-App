import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class EmptyPaymentMethods extends StatelessWidget {
  const EmptyPaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LNDText.regular(
        text: 'No payment method available.',
        color: colors.textMuted,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
