import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/models/pricing_policy.model.dart';
import 'package:lend/core/services/remote_config.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/booking_payment/booking_payment.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/presentation/pages/booking_payment/components/booking_summary_section.component.dart';
import 'package:lend/presentation/pages/booking_payment/helpers/booking_payment_due_today.helper.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_method_row.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/qr_payment_view.widget.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/selected_payment_method_leading.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingPaymentPage extends GetView<BookingPaymentController> {
  static const routeName = '/booking-payment';

  const BookingPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return PopScope(
      canPop: !controller.isRecoveredPendingCheckout,
      onPopInvokedWithResult: (_, __) => controller.onWillPop(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          leading: LNDButton.back(
            onPressed: controller.requestClosePaymentPage,
          ),
          title: LNDText.bold(text: 'Payment', fontSize: 18.0),
          actionsPadding: const EdgeInsets.only(right: 24.0),
          actions: [
            LNDButton.icon(
              icon: Icons.info_outline_rounded,
              size: 25.0,
              onPressed: controller.openRecurringPaymentInfo,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            children: [
              const BookingSummarySection(),

              const SizedBox(height: 16.0),
              Obx(() {
                final method = controller.selectedPaymentMethod.value;
                return BookingPaymentMethodRow(
                  label:
                      controller.isRecoveredCheckout
                          ? 'Pending payment'
                          : method?.displayLabel ?? 'Select payment method',
                  leading:
                      method == null
                          ? null
                          : SelectedPaymentMethodLeading(method: method),
                  onTap: controller.selectPaymentMethod,
                  subtitle:
                      _isCancellableButNonRefundable(method)
                          ? 'Rental is non-refundable through provider; deposit handled by support'
                          : null,
                );
              }),
              const SizedBox(height: 16.0),

              Obx(() {
                final selectedMethod = controller.selectedPaymentMethod.value;
                final policy = LNDRemoteConfigService.pricingPolicy;
                final policyText = cancellationPolicyText(
                  policy: policy.renterCancellationPolicy,
                  startDate: controller.startDate,
                  isNonRefundableMethod: _isNonRefundablePaymentMethod(
                    selectedMethod,
                  ),
                );

                return LNDInfoBanner(
                  content: LNDText.regular(
                    text: policyText,
                    color: colors.textMuted,
                    fontSize: 12.0,
                    overflow: TextOverflow.visible,
                  ),
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
            child: Obx(() {
              final selectedMethod = controller.selectedPaymentMethod.value;
              var buttonText = controller.primaryActionText;
              if (!controller.isRecoveredCheckout && selectedMethod != null) {
                final dueToday = BookingPaymentDueTodayHelper.calculate(
                  asset: controller.asset,
                  startDate: controller.startDate,
                  endDate: controller.endDate,
                  totalPrice: controller.totalPrice,
                  policy: LNDRemoteConfigService.pricingPolicy,
                  selectedPaymentMethod: selectedMethod,
                  payerCountryShortName:
                      ProfileController
                          .instance
                          .user
                          ?.location
                          ?.countryShortName,
                );
                buttonText = 'Book and pay ${dueToday.totalDueLabel}';
              }

              return LNDButton.primary(
                text: buttonText,
                enabled: controller.canBook,
                isLoading: controller.isLoading.value,
                onPressed: controller.book,
              );
            }),
          ),
        ),
      ),
    );
  }
}

bool _isNonRefundablePaymentMethod(LNDSelectedPaymentMethod? method) {
  if (method == null) return false;
  if (method.methodType == 'qrph') return true;
  return method.methodType == 'dob' && method.details['bank_code'] == 'ubp';
}

bool _isCancellableButNonRefundable(LNDSelectedPaymentMethod? method) {
  if (method == null) return false;
  if (method.methodType == 'qrph') return true;
  return method.methodType == 'dob' && method.details['bank_code'] == 'ubp';
}
