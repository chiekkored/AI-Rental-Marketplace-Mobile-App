import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingVehicleDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'vehicle';

  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final seatsController = TextEditingController(text: '1');
  final mileageLimitKmPerDayController = TextEditingController();

  final transmission = 'automatic'.obs;
  final fuelType = 'gasoline'.obs;
  final licenseRequired = true.obs;
  final helmetIncluded = false.obs;
  final deliveryAvailable = false.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    for (final controller in [
      makeController,
      modelController,
      yearController,
    ]) {
      controller.addListener(_updateCanContinue);
    }
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value =
        makeController.text.trim().isNotEmpty &&
        modelController.text.trim().isNotEmpty &&
        yearController.text.trim().isNotEmpty;
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  int? _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim());
  }

  int _parsePositiveInt(
    TextEditingController controller, {
    required int fallback,
  }) {
    final value = _parseInt(controller);
    if (value == null || value < 1) return fallback;
    return value;
  }

  @override
  VehicleListingDetails toListingDetails() {
    return VehicleListingDetails(
      make: makeController.text.trim(),
      model: modelController.text.trim(),
      year: _parseInt(yearController),
      transmission: transmission.value,
      fuelType: fuelType.value,
      seats: _parsePositiveInt(seatsController, fallback: 1),
      mileageLimitKmPerDay: _parseInt(mileageLimitKmPerDayController),
      licenseRequired: licenseRequired.value,
      helmetIncluded: helmetIncluded.value,
      deliveryAvailable: deliveryAvailable.value,
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final vehicleDetails =
        details is VehicleListingDetails
            ? details
            : VehicleListingDetails.fromMap(details.toMap());
    makeController.text = vehicleDetails.make;
    modelController.text = vehicleDetails.model;
    yearController.text = vehicleDetails.year?.toString() ?? '';
    seatsController.text =
        vehicleDetails.seats != null && vehicleDetails.seats! >= 1
            ? vehicleDetails.seats.toString()
            : '1';
    mileageLimitKmPerDayController.text =
        vehicleDetails.mileageLimitKmPerDay?.toString() ?? '';
    transmission.value = vehicleDetails.transmission;
    fuelType.value = vehicleDetails.fuelType;
    licenseRequired.value = vehicleDetails.licenseRequired;
    helmetIncluded.value = vehicleDetails.helmetIncluded;
    deliveryAvailable.value = vehicleDetails.deliveryAvailable;
    _updateCanContinue();
  }

  @override
  void onClose() {
    for (final controller in [
      makeController,
      modelController,
      yearController,
    ]) {
      controller
        ..removeListener(_updateCanContinue)
        ..dispose();
    }
    seatsController.dispose();
    mileageLimitKmPerDayController.dispose();
    transmission.close();
    fuelType.close();
    licenseRequired.close();
    helmetIncluded.close();
    deliveryAvailable.close();
    canContinue.close();
  }
}
