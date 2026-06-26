import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/warning_banner.common.dart';
import 'package:lend/presentation/controllers/payment_methods/payment_methods.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum NewCardFormMode { add, cvcOnly }

class NewCardForm extends StatefulWidget {
  final NewCardFormMode mode;

  const NewCardForm({this.mode = NewCardFormMode.add, super.key});

  @override
  State<NewCardForm> createState() => _NewCardFormState();
}

class _NewCardFormState extends State<NewCardForm> {
  final PaymentMethodsController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.cardNumberController.addListener(_refresh);
    controller.expMonthController.addListener(_refresh);
    controller.expYearController.addListener(_refresh);
    controller.cvcController.addListener(_refresh);
  }

  @override
  void dispose() {
    controller.cardNumberController.removeListener(_refresh);
    controller.expMonthController.removeListener(_refresh);
    controller.expYearController.removeListener(_refresh);
    controller.cvcController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool get _canApply {
    if (_isCvcOnly) return controller.cvcController.text.trim().isNotEmpty;

    return controller.cardNumberController.text.trim().isNotEmpty &&
        controller.expMonthController.text.trim().isNotEmpty &&
        controller.expYearController.text.trim().isNotEmpty &&
        controller.cvcController.text.trim().isNotEmpty;
  }

  bool get _isCvcOnly => widget.mode == NewCardFormMode.cvcOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LNDText.bold(
                        text: _isCvcOnly ? 'Use Card' : 'Add New Card',
                        fontSize: 18.0,
                      ),
                    ),
                    LNDButton.close(),
                  ],
                ),
                const SizedBox(height: 12.0),
                CreditCardWidget(
                  cardNumber: controller.cardNumberController.text,
                  expiryDate: _expiryDate,
                  cardHolderName: '',
                  cvvCode: controller.cvcController.text,
                  showBackView: controller.cvcController.text.isNotEmpty,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: false,
                  cardBgColor: colors.primary,
                  enableFloatingCard: true,
                  onCreditCardWidgetChange: (_) {},
                ),
                const SizedBox(height: 12.0),
                _CardTextFields(controller: controller, isCvcOnly: _isCvcOnly),
                if (!_isCvcOnly) ...[
                  const SizedBox(height: 8.0),
                  if (controller.isSaveCardRequiredForRecurring) ...[
                    LNDWarningBanner(
                      content: LNDText.regular(
                        text:
                            'Recurring card payments may require subscription authorization.',
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                  if (LNDPaymentService.isCardSavingEnabled)
                    Obx(
                      () => SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: controller.shouldSaveCard.value,
                        onChanged:
                            controller.canToggleSaveCard
                                ? (value) =>
                                    controller.shouldSaveCard.value = value
                                : null,
                        title: LNDText.medium(text: 'Save card'),
                      ),
                    )
                  else if (kDebugMode)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LNDText.regular(
                        text: 'Debug: card saving disabled',
                        color: colors.textMuted,
                        fontSize: 12.0,
                      ),
                    ),
                ],
                const SizedBox(height: 8.0),
                LNDButton.primary(
                  text: _isCvcOnly ? 'Use Card' : 'Apply',
                  enabled: _canApply,
                  onPressed:
                      !_canApply
                          ? null
                          : _isCvcOnly
                          ? controller.applySavedCardCvc
                          : controller.applyNewCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _expiryDate {
    final month = controller.expMonthController.text.trim();
    final year = controller.expYearController.text.trim();
    if (month.isEmpty && year.isEmpty) return '';
    final shortYear = year.length > 2 ? year.substring(year.length - 2) : year;
    return '$month/$shortYear';
  }
}

class _CardTextFields extends StatelessWidget {
  final PaymentMethodsController controller;
  final bool isCvcOnly;

  const _CardTextFields({required this.controller, required this.isCvcOnly});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Column(
      children: [
        TextFormField(
          controller: controller.cardNumberController,
          style: LNDText.regularStyle.copyWith(
            color: isCvcOnly ? colors.textMuted : colors.textPrimary,
          ),
          keyboardType: isCvcOnly ? TextInputType.text : TextInputType.number,
          maxLength: 23,
          readOnly: isCvcOnly,
          inputFormatters:
              isCvcOnly
                  ? const []
                  : [
                    FilteringTextInputFormatter.digitsOnly,
                    const _CardNumberInputFormatter(),
                  ],
          decoration: LNDTextField.inputDecoration(
            colors: colors,
            labelText: 'Card Number',
            borderRadius: 8.0,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: LNDTextField.regular(
                controller: controller.expMonthController,
                keyboardType: TextInputType.number,
                labelText: 'MM',
                displayCommas: false,
                maxLength: 2,
                borderRadius: 8.0,
                readOnly: isCvcOnly,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: LNDTextField.regular(
                controller: controller.expYearController,
                keyboardType: TextInputType.number,
                labelText: 'YYYY',
                displayCommas: false,
                maxLength: 4,
                borderRadius: 8.0,
                readOnly: isCvcOnly,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: LNDTextField.regular(
                controller: controller.cvcController,
                keyboardType: TextInputType.number,
                labelText: 'CVC',
                displayCommas: false,
                maxLength: 4,
                borderRadius: 8.0,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  const _CardNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 19 ? digits.substring(0, 19) : digits;
    final digitsBeforeCursor = newValue.text
        .substring(0, newValue.selection.end)
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, limitedDigits.length);
    final formatted = _format(limitedDigits);
    final offset = _offsetForDigitCount(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  String _format(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  int _offsetForDigitCount(String formatted, int digitCount) {
    if (digitCount <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) seen++;
      if (seen == digitCount) return i + 1;
    }
    return formatted.length;
  }
}
