import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentCardBrandIcon extends StatelessWidget {
  final String? brand;
  final String? cardNumber;
  final double size;

  const PaymentCardBrandIcon({
    this.brand,
    this.cardNumber,
    this.size = 22.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final resolvedBrand =
        cardNumber == null
            ? LNDCardBrand.fromLabel(brand)
            : LNDCardBrand.detect(cardNumber!);
    final color = switch (resolvedBrand) {
      LNDCardBrand.visa => const Color(0xFF1434CB),
      LNDCardBrand.mastercard => const Color(0xFFEB001B),
      LNDCardBrand.amex => const Color(0xFF2E77BB),
      LNDCardBrand.discover => const Color(0xFFF58220),
      LNDCardBrand.jcb => const Color(0xFF0B4EA2),
      LNDCardBrand.card => colors.textPrimary,
    };

    return FaIcon(_iconFor(resolvedBrand), size: size, color: color);
  }

  IconData _iconFor(LNDCardBrand brand) {
    return switch (brand) {
      LNDCardBrand.visa => FontAwesomeIcons.ccVisa,
      LNDCardBrand.mastercard => FontAwesomeIcons.ccMastercard,
      LNDCardBrand.amex => FontAwesomeIcons.ccAmex,
      LNDCardBrand.discover => FontAwesomeIcons.ccDiscover,
      LNDCardBrand.jcb => FontAwesomeIcons.ccJcb,
      LNDCardBrand.card => FontAwesomeIcons.creditCard,
    };
  }
}
