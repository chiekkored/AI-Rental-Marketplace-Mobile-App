import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/bank_payment_tile.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/empty_payment_methods.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_accordion.widget.dart';

class BankingPaymentSection extends GetView<PaymentMethodsController> {
  const BankingPaymentSection({super.key});

  static const _assetPath = 'assets/images/payment';

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PaymentMethodAccordion(
        title: 'Online banking',
        initiallyExpanded: controller.isBankSectionExpanded.value,
        onExpansionChanged: controller.setBankSectionExpanded,
        child:
            controller.hasVisibleBankPaymentMethods
                ? const Column(
                  children: [
                    BankPaymentTile(
                      id: 'bpi',
                      label: 'BPI',
                      methodType: 'dob',
                      bankCode: 'bpi',
                      logoAsset: '$_assetPath/bpi.png',
                    ),
                    BankPaymentTile(
                      id: 'ubp',
                      label: 'UnionBank',
                      methodType: 'dob',
                      bankCode: 'ubp',
                      logoAsset: '$_assetPath/unionbank.png',
                    ),
                    BankPaymentTile(
                      id: 'bdo',
                      label: 'BDO',
                      methodType: 'brankas',
                      bankCode: 'bdo',
                      logoAsset: '$_assetPath/bdo.png',
                    ),
                    BankPaymentTile(
                      id: 'landbank',
                      label: 'Landbank',
                      methodType: 'brankas',
                      bankCode: 'landbank',
                      logoAsset: '$_assetPath/landbank.png',
                    ),
                    BankPaymentTile(
                      id: 'metrobank',
                      label: 'Metrobank',
                      methodType: 'brankas',
                      bankCode: 'metrobank',
                      logoAsset: '$_assetPath/metrobank.png',
                    ),
                  ],
                )
                : const EmptyPaymentMethods(),
      ),
    );
  }
}
