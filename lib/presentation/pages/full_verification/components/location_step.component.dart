import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class LocationStepComponent extends GetView<FullVerificationController> {
  const LocationStepComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return GetBuilder<LocationPickerController>(
      init: LocationPickerController(
        locationCallback: controller.initialLocationCallback,
      ),
      builder: (picker) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.bold(text: 'Address', fontSize: 26.0),
                    const SizedBox(height: 8.0),
                    LNDText.regular(
                      text:
                          'Search for your address or place the pin manually on the map.',
                      color: colors.textMuted,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 16.0),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: picker.locationController,
                      googleAPIKey:
                          dotenv.env['GOOGLE_MAPS_PLACES_API_KEY'] ?? '',
                      isLatLngRequired: true,
                      textStyle: LNDText.regularStyle,
                      containerVerticalPadding: 0,
                      boxDecoration: const BoxDecoration(),
                      inputDecoration: LNDTextField.inputDecoration(
                        colors: colors,
                        hintText: 'Search address',
                        borderRadius: 12.0,
                        suffixIcon: Icons.close,
                        onTapSuffix: picker.clearLocation,
                      ),
                      isCrossBtnShown: false,
                      getPlaceDetailWithLatLng: (prediction) {
                        picker.selectPlaceLocation(
                          LatLng(
                            double.tryParse(prediction.lat ?? '') ?? 0,
                            double.tryParse(prediction.lng ?? '') ?? 0,
                          ),
                        );
                      },
                      itemClick: (prediction) {
                        picker.locationController.text =
                            prediction.description ?? '';
                        picker.setAddressDetails(prediction);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      itemBuilder: (_, __, prediction) {
                        return ListTile(
                          title: LNDText.regular(
                            text: prediction.description ?? '',
                            fontSize: 12.0,
                            textAlign: TextAlign.start,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Obx(
                      () => GoogleMap(
                        buildingsEnabled: false,
                        initialCameraPosition: picker.cameraPosition.value,
                        onMapCreated: picker.onMapCreated,
                        markers: picker.marker.toSet(),
                        circles: picker.circle.toSet(),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        onCameraMove: picker.updatePinnedPositionFromCamera,
                        onCameraIdle: picker.onCameraIdle,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -18),
                      child: Center(
                        child: Icon(
                          Icons.location_pin,
                          color: colors.primary,
                          size: 42.0,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      top: 16.0,
                      child: LNDButton.widget(
                        color: colors.surface,
                        borderRadius: 12.0,
                        size: 44.0,
                        onPressed: picker.getToCurrentLocation,
                        child: const Icon(Icons.near_me_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: colors.surface,
                padding: const EdgeInsets.all(20.0),
                child: Obx(
                  () => LNDButton.primary(
                    text: 'Confirm address',
                    enabled: true,
                    borderRadius: 12.0,
                    isLoading: picker.isConfirmingLocation,
                    onPressed: () async {
                      final location = await picker.confirmSelectedLocation();
                      if (location == null) return;

                      controller.setLocationFromPicker(location);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
