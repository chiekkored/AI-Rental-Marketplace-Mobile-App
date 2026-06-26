import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PickLocationPage extends StatelessWidget {
  static const routeName = '/create-listing/pick-location';
  const PickLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as LocationCallbackModel?;
    final colors = context.lndTheme;
    return GetBuilder<LocationPickerController>(
      init: LocationPickerController(locationCallback: args),
      builder: (controller) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              surfaceTintColor: colors.background,
              leading: LNDButton.back(),
              title: LNDText.bold(text: 'Pick Location', fontSize: 18),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LNDText.bold(
                          text: 'Pick Location',
                          fontSize: 26,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 8),
                        LNDText.regular(
                          text:
                              'Search for a location or place the pin manually on the map.',
                          color: colors.textMuted,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 16),
                        GooglePlaceAutoCompleteTextField(
                          textEditingController: controller.locationController,
                          googleAPIKey:
                              dotenv.env['GOOGLE_MAPS_PLACES_API_KEY'] ?? '',
                          isLatLngRequired: true,
                          textStyle: LNDText.regularStyle,
                          containerVerticalPadding: 0,
                          boxDecoration: const BoxDecoration(),
                          inputDecoration: LNDTextField.inputDecoration(
                            hintText: 'Search location',
                            borderRadius: 12,
                            suffixIcon: Icons.close,
                            onTapSuffix: controller.clearLocation,
                            colors: colors,
                          ),
                          isCrossBtnShown: false,
                          getPlaceDetailWithLatLng: (prediction) {
                            controller.selectPlaceLocation(
                              LatLng(
                                double.tryParse(prediction.lat ?? '') ?? 0,
                                double.tryParse(prediction.lng ?? '') ?? 0,
                              ),
                            );
                          },
                          itemClick: (prediction) {
                            controller.locationController.text =
                                prediction.description ?? '';
                            controller.setAddressDetails(prediction);
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          itemBuilder: (_, __, prediction) {
                            return ListTile(
                              title: LNDText.regular(
                                text: prediction.description ?? '',
                                fontSize: 12,
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
                            initialCameraPosition:
                                controller.cameraPosition.value,
                            onMapCreated: controller.onMapCreated,
                            markers: controller.marker.toSet(),
                            circles: controller.circle.toSet(),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            onCameraMove:
                                controller.updatePinnedPositionFromCamera,
                            onCameraIdle: controller.onCameraIdle,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: Center(
                            child: Icon(
                              Icons.location_pin,
                              color: colors.primary,
                              size: 42,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 16,
                          child: LNDButton.widget(
                            color: colors.surface,
                            borderRadius: 12,
                            size: 44,
                            onPressed: controller.getToCurrentLocation,
                            child: const Icon(Icons.near_me_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      color: colors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Obx(
                        () => LNDButton.primary(
                          text: 'Confirm Location',
                          enabled: controller.pinnedPosition != null,
                          borderRadius: 12,
                          isLoading: controller.isConfirmingLocation,
                          onPressed: controller.applyLocation,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
