import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/empty_saved_cards.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/new_card_form.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_card_logo.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_accordion.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_method_tile.widget.dart';
import 'package:lend/presentation/pages/payment_methods/widgets/payment_methods_shimmer.widget.dart';

class CardPaymentSection extends GetView<PaymentMethodsController> {
  const CardPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isCardPaymentVisible) return const SizedBox.shrink();
      return PaymentMethodAccordion(
        title: 'Cards',
        initiallyExpanded: controller.isCardSectionExpanded.value,
        onExpansionChanged: controller.setCardSectionExpanded,
        child: Column(
          children: [
            if (controller.isLoadingSavedMethods.value)
              const PaymentMethodsShimmer()
            else ...[
              for (final method in controller.visibleSavedMethods)
                PaymentMethodTile(
                  icon: Icons.credit_card_rounded,
                  leading: PaymentCardLogo(
                    brand: method.brand,
                    cardNumber: method.cardNumber,
                  ),
                  label: method.displayLabel,
                  subtitle:
                      controller.isCardPaymentEnabled
                          ? method.subtitle ??
                              (method.isLocal
                                  ? 'Not submitted yet'
                                  : method.sessionType)
                          : 'Unavailable',
                  enabled: controller.isCardPaymentEnabled,
                  isSelected: controller.isCardSelected(method),
                  onTap: () {
                    controller.prepareSavedCardForm(method);
                    Get.bottomSheet<void>(
                      const NewCardForm(mode: NewCardFormMode.cvcOnly),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              if (controller.visibleSavedMethods.isEmpty)
                const EmptySavedCards(),
            ],
            const SizedBox(height: 12.0),
            LNDButton.secondary(
              text: 'Add New Card',
              enabled: controller.isCardPaymentEnabled,
              icon: Icons.add_card_rounded,
              iconSize: 20.0,
              onPressed: () {
                controller.prepareNewCardForm();
                Get.bottomSheet<void>(
                  const NewCardForm(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
