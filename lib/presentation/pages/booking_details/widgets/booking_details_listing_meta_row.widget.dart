import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsListingMetaRow extends StatelessWidget {
  const BookingDetailsListingMetaRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LNDText.regular(
          text: '$label: ',
          color: colors.textMuted,
          fontSize: 12.0,
          overflow: TextOverflow.visible,
        ),
        Expanded(
          child: LNDText.medium(
            text: value,
            fontSize: 12.0,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
