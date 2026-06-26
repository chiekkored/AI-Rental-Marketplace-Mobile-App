import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class LNDCurrencyMismatchBanner extends StatelessWidget {
  const LNDCurrencyMismatchBanner({
    required this.activeCurrencyCode,
    required this.selectedCurrencyCode,
    super.key,
  });

  final String activeCurrencyCode;
  final String selectedCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: LNDNavigate.toCountryCurrencyPickerPage,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.warningSoft,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: colors.warning),
                const SizedBox(width: 10.0),
                Expanded(
                  child: LNDText.regular(
                    text: 'Listings use',
                    color: colors.textPrimary,
                    overflow: TextOverflow.visible,
                    fontSize: 12.0,
                    textParts: [
                      LNDText.bold(
                        text: ' $activeCurrencyCode ',
                        fontSize: 12.0,
                      ),
                      LNDText.regular(
                        text:
                            'for this location. Your selected '
                            'display currency is',
                        fontSize: 12.0,
                      ),
                      LNDText.bold(
                        text: ' $selectedCurrencyCode.',
                        fontSize: 12.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
