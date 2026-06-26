import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsRoleChip extends StatelessWidget {
  const BookingDetailsRoleChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final isOwner = label == 'Your Unit';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: isOwner ? colors.infoSoft : colors.primarySoft,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: LNDText.semibold(
        text: label,
        fontSize: 10.0,
        color: isOwner ? colors.info : colors.primary,
      ),
    );
  }
}
