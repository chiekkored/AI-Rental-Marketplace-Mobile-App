import 'package:flutter/material.dart';
import 'package:lend/core/models/country_option.model.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CountryPickerTile extends StatelessWidget {
  final CountryOption option;
  final bool isCurrencyMode;
  final VoidCallback onTap;

  const CountryPickerTile({
    super.key,
    required this.option,
    required this.isCurrencyMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final leadingText = isCurrencyMode ? option.currencyCode : option.phoneCode;

    return ListTile(
      dense: true,
      onTap: onTap,
      leading: SizedBox(
        width: 52,
        child: LNDText.medium(
          text: leadingText,
          color: colors.textPrimary,
          textAlign: TextAlign.start,
        ),
      ),
      title: LNDText.regular(text: '${option.flag} ${option.countryName}'),
      subtitle:
          isCurrencyMode
              ? LNDText.regular(
                text: option.currencyValue,
                color: colors.textMuted,
                fontSize: 12,
              )
              : null,
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
    );
  }
}
