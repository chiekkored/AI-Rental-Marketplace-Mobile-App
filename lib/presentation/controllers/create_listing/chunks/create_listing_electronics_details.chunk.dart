import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingElectronicsDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'electronics';

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final compatibilityNoteController = TextEditingController();
  final specsNoteController = TextEditingController();

  final batteryIncluded = false.obs;
  final chargerIncluded = false.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    brandController.addListener(_updateCanContinue);
    modelController.addListener(_updateCanContinue);
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value =
        brandController.text.trim().isNotEmpty &&
        modelController.text.trim().isNotEmpty;
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  @override
  ElectronicsListingDetails toListingDetails() {
    return ElectronicsListingDetails(
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      batteryIncluded: batteryIncluded.value,
      chargerIncluded: chargerIncluded.value,
      compatibilityNote: compatibilityNoteController.text.trim(),
      specsNote: specsNoteController.text.trim(),
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final electronicsDetails =
        details is ElectronicsListingDetails
            ? details
            : ElectronicsListingDetails.fromMap(details.toMap());
    brandController.text = electronicsDetails.brand;
    modelController.text = electronicsDetails.model;
    batteryIncluded.value = electronicsDetails.batteryIncluded;
    chargerIncluded.value = electronicsDetails.chargerIncluded;
    compatibilityNoteController.text = electronicsDetails.compatibilityNote;
    specsNoteController.text = electronicsDetails.specsNote;
    _updateCanContinue();
  }

  @override
  void onClose() {
    brandController
      ..removeListener(_updateCanContinue)
      ..dispose();
    modelController
      ..removeListener(_updateCanContinue)
      ..dispose();
    compatibilityNoteController.dispose();
    specsNoteController.dispose();
    batteryIncluded.close();
    chargerIncluded.close();
    canContinue.close();
  }
}
