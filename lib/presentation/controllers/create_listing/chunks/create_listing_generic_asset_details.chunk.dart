import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingGenericAssetDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'generic_asset';

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final notesController = TextEditingController();

  @override
  final canContinue = true.obs;

  @override
  void onInit() {}

  @override
  bool validate() => formKey.currentState?.validate() != false;

  @override
  GenericAssetListingDetails toListingDetails() {
    return GenericAssetListingDetails(
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      notes: notesController.text.trim(),
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final genericDetails =
        details is GenericAssetListingDetails
            ? details
            : GenericAssetListingDetails.fromMap(details.toMap());
    brandController.text = genericDetails.brand;
    modelController.text = genericDetails.model;
    notesController.text = genericDetails.notes;
  }

  @override
  void onClose() {
    brandController.dispose();
    modelController.dispose();
    notesController.dispose();
    canContinue.close();
  }
}
