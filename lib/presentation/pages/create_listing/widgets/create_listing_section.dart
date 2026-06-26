import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final bool required;

  const CreateListingSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            LNDText.bold(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.start,
              required: required,
            ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            LNDText.regular(
              text: description,
              fontSize: 12,
              color: colors.textMuted,
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
