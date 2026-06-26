import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingToolDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'tool';

  final brandController = TextEditingController();
  final modelController = TextEditingController();

  final powerSource = 'battery'.obs;
  final skillLevel = 'beginner'.obs;
  final safetyGearRequired = false.obs;
  final consumablesIncluded = false.obs;
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
  ToolListingDetails toListingDetails() {
    return ToolListingDetails(
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      powerSource: powerSource.value,
      safetyGearRequired: safetyGearRequired.value,
      consumablesIncluded: consumablesIncluded.value,
      skillLevel: skillLevel.value,
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final toolDetails =
        details is ToolListingDetails
            ? details
            : ToolListingDetails.fromMap(details.toMap());
    brandController.text = toolDetails.brand;
    modelController.text = toolDetails.model;
    powerSource.value = toolDetails.powerSource;
    skillLevel.value = toolDetails.skillLevel;
    safetyGearRequired.value = toolDetails.safetyGearRequired;
    consumablesIncluded.value = toolDetails.consumablesIncluded;
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
    powerSource.close();
    skillLevel.close();
    safetyGearRequired.close();
    consumablesIncluded.close();
    canContinue.close();
  }
}
