import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NowRoleChip extends StatelessWidget {
  const NowRoleChip({super.key, required this.item});

  final NowBookingItem item;

  @override
  Widget build(BuildContext context) {
    final isOwner = item.role == NowBookingRole.owner;
    final colors = context.lndTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: isOwner ? colors.infoSoft : colors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: LNDText.semibold(
        text: item.roleLabel,
        fontSize: 10.0,
        color: isOwner ? colors.info : colors.primary,
      ),
    );
  }
}
