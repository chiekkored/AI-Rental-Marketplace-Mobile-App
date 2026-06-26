import 'package:flutter/material.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentLogo extends StatelessWidget {
  final IconData fallbackIcon;
  final String? asset;

  const PaymentLogo({required this.fallbackIcon, this.asset, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      height: 36.0,
      width: 48.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
      child:
          asset == null
              ? Icon(fallbackIcon, color: colors.textPrimary, size: 22.0)
              : Image.asset(
                asset!,
                height: 24.0,
                width: 40.0,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Icon(
                      fallbackIcon,
                      color: colors.textPrimary,
                      size: 22.0,
                    ),
              ),
    );
  }
}
