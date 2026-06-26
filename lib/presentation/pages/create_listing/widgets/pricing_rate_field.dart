import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/controllers/country_preference/country_preference.controller.dart';

class PricingRateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const PricingRateField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LNDTextField.regular(
        controller: controller,
        labelText: label,
        prefixText:
            CountryPreferenceController
                .instance
                .currencyCountry
                .value
                .currencyPrefix,
        borderRadius: 12,
        keyboardType: TextInputType.number,
        displayCommas: true,
      ),
    );
  }
}
