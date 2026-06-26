import 'package:flutter/material.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_card_brand_icon.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_logo.widget.dart';

class SelectedPaymentMethodLeading extends StatelessWidget {
  final LNDSelectedPaymentMethod? method;

  const SelectedPaymentMethodLeading({required this.method, super.key});

  @override
  Widget build(BuildContext context) {
    final selected = method;
    if (selected == null) return const SizedBox.shrink();

    if (selected.isCard) {
      return PaymentCardBrandIcon(
        brand: selected.brand,
        cardNumber: selected.cardNumber,
      );
    }

    if (selected.logoAsset != null) {
      return PaymentLogo(
        fallbackIcon: Icons.payments_outlined,
        asset: selected.logoAsset,
      );
    }

    return const SizedBox.shrink();
  }
}
