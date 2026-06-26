import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_price_breakdown.helper.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class AssetAllPricesSheet extends GetView<AssetController> {
  const AssetAllPricesSheet({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final rates = controller.asset?.rates;
    final enabledRates = BookingPriceBreakdown.enabledRates(rates);
    final notes = controller.asset?.rates?.notes;
    final currencyCode = LNDMoney.currencyCodeFromRates(
      controller.asset?.rates,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: 'Other rates', fontSize: 18.0),
            const SizedBox(height: 4.0),
            LNDText.regular(
              text: 'Available pricing options for this listing.',
              color: colors.textMuted,
              fontSize: 12.0,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 16.0),
            if (enabledRates.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: LNDText.regular(
                  text: 'No other rates available.',
                  color: colors.textMuted,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < enabledRates.length; index++)
                      _RateRow(
                        line: enabledRates[index],
                        currencyCode: currencyCode,
                        icon: _rateIcon(enabledRates[index].unit),
                        showDivider: index < enabledRates.length - 1,
                      ),
                  ],
                ),
              ),
            if (notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LNDText.semibold(text: 'Notes', fontSize: 14.0),
                    const SizedBox(height: 6.0),
                    LNDText.regular(
                      text: notes!.trim(),
                      color: colors.textMuted,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _rateIcon(String unit) {
    return switch (unit) {
      'day' => Icons.calendar_view_day_rounded,
      'week' => Icons.calendar_view_week_rounded,
      'month' => Icons.calendar_view_month_rounded,
      _ => Icons.calendar_month_rounded,
    };
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.line,
    required this.currencyCode,
    required this.icon,
    required this.showDivider,
  });

  final BookingEnabledRateLine line;
  final String currencyCode;
  final IconData icon;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                height: 36.0,
                width: 36.0,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Icon(icon, color: colors.textPrimary, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(child: LNDText.semibold(text: line.label)),
              const SizedBox(width: 12.0),
              Flexible(
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: LNDMoney.format(
                          line.amount,
                          currencyCode: currencyCode,
                        ),
                        style: LNDText.boldStyle.copyWith(
                          color: colors.textPrimary,
                          fontSize: 14.0,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${line.unit}',
                        style: LNDText.regularStyle.copyWith(
                          color: colors.textMuted,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: Divider(height: 1.0, color: colors.outline),
          ),
      ],
    );
  }
}
