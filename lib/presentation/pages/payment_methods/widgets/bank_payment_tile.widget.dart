import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_tile.widget.dart';

class BankPaymentTile extends GetWidget<PaymentMethodsController> {
  final String id;
  final String label;
  final String methodType;
  final String bankCode;
  final String? logoAsset;

  const BankPaymentTile({
    required this.id,
    required this.label,
    required this.methodType,
    required this.bankCode,
    this.logoAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.isPaymentMethodVisible(id)) return const SizedBox.shrink();
    return PaymentMethodTile(
      icon: Icons.account_balance_outlined,
      logoAsset: logoAsset,
      label: label,
      enabled: controller.isPaymentMethodEnabled(id),
      isSelected: controller.isChannelSelected(methodType, bankCode: bankCode),
      onTap:
          () => controller.useChannel(
            LNDSelectedPaymentMethod.channel(
              methodType: methodType,
              label: label,
              details: {'bank_code': bankCode},
              logoAsset: logoAsset,
            ),
          ),
    );
  }
}
