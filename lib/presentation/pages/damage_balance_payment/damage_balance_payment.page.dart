import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_method_row.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_section.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/qr_payment_view.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/selected_payment_method_leading.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/summary_row.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class DamageBalancePaymentPage extends GetView<DamageBalancePaymentController> {
  static const routeName = '/damage-balance-payment';

  const DamageBalancePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Damage payment', fontSize: 18.0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          children: [
            BookingPaymentSection(
              child: Obx(() {
                final booking = controller.booking.value;
                final assetTitle =
                    booking?.asset?.title ?? controller.args.chat.asset?.title;
                final processingFee = controller.displayProcessingFee;
                final hasPaymentMethod =
                    controller.selectedPaymentMethod.value != null;
                final depositReturnAmount =
                    booking?.depositFlow?.depositReturnAmount;
                final approvedDamageAmount =
                    booking?.disputeFlow?.approvedAmount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.bold(text: assetTitle ?? 'Damage balance'),
                    const Divider(height: 28.0),
                    LNDText.semibold(text: 'Damage details'),
                    const SizedBox(height: 6.0),
                    BookingSummaryRow(
                      label: 'Booking',
                      value: controller.args.bookingId,
                    ),
                    if (approvedDamageAmount != null)
                      BookingSummaryRow(
                        label: 'Approved damage',
                        value: LNDMoney.format(
                          approvedDamageAmount,
                          currencyCode: controller.args.currency,
                        ),
                      ),
                    if (booking?.securityDeposit.enabled == true)
                      BookingSummaryRow(
                        label: 'Security deposit',
                        value: LNDMoney.format(
                          booking!.securityDeposit.amount,
                          currencyCode: controller.args.currency,
                        ),
                      ),
                    if (depositReturnAmount != null && depositReturnAmount > 0)
                      BookingSummaryRow(
                        label: 'Deposit return',
                        value: LNDMoney.format(
                          depositReturnAmount,
                          currencyCode: controller.args.currency,
                        ),
                      ),
                    const Divider(height: 28.0),
                    LNDText.semibold(text: 'Payment details'),
                    const SizedBox(height: 6.0),
                    BookingSummaryRow(
                      label: 'Outstanding balance',
                      value: LNDMoney.format(
                        controller.args.amount,
                        currencyCode: controller.args.currency,
                      ),
                    ),
                    if (processingFee != null)
                      BookingSummaryRow(
                        label: 'Processing fee',
                        value: LNDMoney.format(
                          processingFee,
                          currencyCode: controller.args.currency,
                        ),
                      ),
                    BookingSummaryRow(
                      label: hasPaymentMethod ? 'Total due' : 'Due before fees',
                      value: LNDMoney.format(
                        controller.displayTotalToPay,
                        currencyCode: controller.args.currency,
                      ),
                      isTotal: true,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16.0),
            Obx(() {
              final method = controller.selectedPaymentMethod.value;
              return BookingPaymentMethodRow(
                label: method?.displayLabel ?? 'Select payment method',
                leading:
                    method == null
                        ? null
                        : SelectedPaymentMethodLeading(method: method),
                onTap: controller.selectPaymentMethod,
                subtitle:
                    _isCancellableButNonRefundable(method)
                        ? 'Cancellable but non-refundable'
                        : null,
              );
            }),
            const SizedBox(height: 16.0),
            Obx(
              () =>
                  controller.qrImageUrl.value == null
                      ? const SizedBox.shrink()
                      : QrPaymentView(dataUri: controller.qrImageUrl.value!),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: kBottomNavigationBarHeight + 20.0,
        child: ColoredBox(
          color: colors.surface,
          child: Obx(
            () => LNDButton.primary(
              text:
                  'Pay ${LNDMoney.format(controller.displayTotalToPay, currencyCode: controller.args.currency)}',
              enabled: controller.canPay,
              isLoading: controller.isLoading.value,
              onPressed: controller.pay,
            ),
          ),
        ),
      ),
    );
  }
}

bool _isCancellableButNonRefundable(LNDSelectedPaymentMethod? method) {
  if (method == null) return false;
  if (method.methodType == 'qrph') return true;
  return method.methodType == 'dob' && method.details['bank_code'] == 'ubp';
}
