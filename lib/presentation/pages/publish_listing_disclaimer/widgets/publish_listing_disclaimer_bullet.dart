import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PublishListingDisclaimerBullet extends StatelessWidget {
  final String text;

  const PublishListingDisclaimerBullet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            Icons.check_circle_outline,
            color: colors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LNDText.regular(
            text: text,
            color: colors.textPrimary,
            fontSize: 14,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
