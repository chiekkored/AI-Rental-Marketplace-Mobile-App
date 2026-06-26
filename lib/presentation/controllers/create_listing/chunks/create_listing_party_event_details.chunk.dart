import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingPartyEventDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'party_event';

  final quantityController = TextEditingController();
  final setSizeController = TextEditingController();
  final setupInstructionsController = TextEditingController();

  final setupRequired = false.obs;
  final deliveryRequired = false.obs;
  final powerRequired = false.obs;
  final indoorOutdoor = 'both'.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    quantityController.addListener(_updateCanContinue);
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value = quantityController.text.trim().isNotEmpty;
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  int? _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim());
  }

  @override
  PartyEventListingDetails toListingDetails() {
    return PartyEventListingDetails(
      quantity: _parseInt(quantityController),
      setSize: setSizeController.text.trim(),
      setupRequired: setupRequired.value,
      deliveryRequired: deliveryRequired.value,
      powerRequired: powerRequired.value,
      indoorOutdoor: indoorOutdoor.value,
      setupInstructions: setupInstructionsController.text.trim(),
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final partyEventDetails =
        details is PartyEventListingDetails
            ? details
            : PartyEventListingDetails.fromMap(details.toMap());
    quantityController.text = partyEventDetails.quantity?.toString() ?? '';
    setSizeController.text = partyEventDetails.setSize;
    setupInstructionsController.text = partyEventDetails.setupInstructions;
    setupRequired.value = partyEventDetails.setupRequired;
    deliveryRequired.value = partyEventDetails.deliveryRequired;
    powerRequired.value = partyEventDetails.powerRequired;
    indoorOutdoor.value = partyEventDetails.indoorOutdoor;
    _updateCanContinue();
  }

  @override
  void onClose() {
    quantityController
      ..removeListener(_updateCanContinue)
      ..dispose();
    setSizeController.dispose();
    setupInstructionsController.dispose();
    setupRequired.close();
    deliveryRequired.close();
    powerRequired.close();
    indoorOutdoor.close();
    canContinue.close();
  }
}
