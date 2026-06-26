import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/empty_payment_methods.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_accordion.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_tile.widget.dart';

class WalletPaymentSection extends GetView<PaymentMethodsController> {
  const WalletPaymentSection({super.key});

  static const _assetPath = 'assets/images/payment';

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PaymentMethodAccordion(
        title: 'E-wallets and QR',
        initiallyExpanded: controller.isWalletSectionExpanded.value,
        onExpansionChanged: controller.setWalletSectionExpanded,
        child: Column(
          children: [
            if (!controller.hasVisibleWalletPaymentMethods)
              const EmptyPaymentMethods()
            else ...[
              if (controller.isPaymentMethodVisible('gcash'))
                PaymentMethodTile(
                  icon: Icons.account_balance_wallet_outlined,
                  logoAsset: '$_assetPath/gcash.png',
                  label: 'GCash',
                  enabled: controller.isPaymentMethodEnabled('gcash'),
                  isSelected: controller.isChannelSelected('gcash'),
                  onTap:
                      () => controller.useChannel(
                        LNDSelectedPaymentMethod.channel(
                          methodType: 'gcash',
                          label: 'GCash',
                          logoAsset: '$_assetPath/gcash.png',
                        ),
                      ),
                ),
              if (controller.isPaymentMethodVisible('paymaya'))
                PaymentMethodTile(
                  icon: Icons.account_balance_wallet_outlined,
                  logoAsset: '$_assetPath/maya.png',
                  label: 'Maya',
                  enabled: controller.isPaymentMethodEnabled('paymaya'),
                  isSelected: controller.isChannelSelected('paymaya'),
                  onTap:
                      () => controller.useChannel(
                        LNDSelectedPaymentMethod.channel(
                          methodType: 'paymaya',
                          label: 'Maya',
                          logoAsset: '$_assetPath/maya.png',
                        ),
                      ),
                ),
              if (!controller.recurringBillingOnly) ...[
                if (controller.isPaymentMethodVisible('grab_pay'))
                  PaymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    logoAsset: '$_assetPath/grab_pay.png',
                    label: 'GrabPay',
                    enabled: controller.isPaymentMethodEnabled('grab_pay'),
                    isSelected: controller.isChannelSelected('grab_pay'),
                    onTap:
                        () => controller.useChannel(
                          LNDSelectedPaymentMethod.channel(
                            methodType: 'grab_pay',
                            label: 'GrabPay',
                            logoAsset: '$_assetPath/grab_pay.png',
                          ),
                        ),
                  ),
                if (controller.isPaymentMethodVisible('shopeepay'))
                  PaymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    logoAsset: '$_assetPath/shopee_pay.png',
                    label: 'ShopeePay',
                    enabled: controller.isPaymentMethodEnabled('shopeepay'),
                    isSelected: controller.isChannelSelected('shopeepay'),
                    onTap:
                        () => controller.useChannel(
                          LNDSelectedPaymentMethod.channel(
                            methodType: 'shopeepay',
                            label: 'ShopeePay',
                            logoAsset: '$_assetPath/shopee_pay.png',
                          ),
                        ),
                  ),
                if (controller.isPaymentMethodVisible('qrph'))
                  PaymentMethodTile(
                    icon: Icons.qr_code_2_rounded,
                    logoAsset: '$_assetPath/qr_ph.png',
                    label: 'QR Ph',
                    enabled: controller.isPaymentMethodEnabled('qrph'),
                    isSelected: controller.isChannelSelected('qrph'),
                    onTap:
                        () => controller.useChannel(
                          LNDSelectedPaymentMethod.channel(
                            methodType: 'qrph',
                            label: 'QR Ph',
                            kind: LNDPaymongoPaymentKind.qr,
                            logoAsset: '$_assetPath/qr_ph.png',
                          ),
                        ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
