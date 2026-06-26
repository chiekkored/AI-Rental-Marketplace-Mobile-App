import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class OutstandingBalanceBanner extends GetView<ProfileController> {
  const OutstandingBalanceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      if (!controller.hasOutstandingDamageBalance) {
        return const SizedBox.shrink();
      }

      final total = controller.outstandingDamageBalanceTotal;
      final amountText = LNDMoney.format(
        total,
        currencyCode: controller.outstandingDamageBalanceCurrency,
      );

      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
        child: Material(
          color: colors.warningSoft,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: controller.goToOutstandingDamageBalances,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.warning),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LNDText.semibold(
                          text: 'Outstanding balance',
                          color: colors.textPrimary,
                        ),
                        const SizedBox(height: 4.0),
                        LNDText.regular(
                          text:
                              'You still have outstanding balance that needs to be paid. Total: $amountText',
                          color: colors.textMuted,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Icon(Icons.chevron_right_rounded, color: colors.warning),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
