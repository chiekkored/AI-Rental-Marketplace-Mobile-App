import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/country_picker/country_picker.controller.dart';
import 'package:lend/presentation/pages/country_picker/widgets/country_picker_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CountryPickerPage extends GetView<CountryPickerController> {
  static const routeName = '/country-picker';
  const CountryPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: controller.title, fontSize: 18.0),
      ),
      body: ColoredBox(
        color: colors.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: LNDTextField.regular(
                controller: controller.searchController,
                hintText: controller.searchHint,
                prefixIcon: Icons.search_rounded,
                prefixIconColor: colors.textMuted,
                prefixIconSize: 18,
                borderRadius: 12,
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child: Obx(() {
                final countries = controller.filteredCountries;
                if (countries.isEmpty) {
                  return Center(
                    child: LNDText.regular(
                      text: 'No countries found',
                      color: colors.textMuted,
                    ),
                  );
                }

                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: countries.length,
                  itemBuilder:
                      (context, index) => CountryPickerTile(
                        option: countries[index],
                        isCurrencyMode: controller.isCurrencyMode,
                        onTap: () => controller.selectCountry(countries[index]),
                      ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
