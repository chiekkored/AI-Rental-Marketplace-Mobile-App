import 'package:flutter/material.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_card_brand_icon.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentCardLogo extends StatelessWidget {
  final String? brand;
  final String? cardNumber;

  const PaymentCardLogo({this.brand, this.cardNumber, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      height: 36.0,
      width: 48.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: PaymentCardBrandIcon(brand: brand, cardNumber: cardNumber),
    );
  }
}
