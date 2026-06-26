import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingClothingDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'clothing';

  final brandController = TextEditingController();
  final sizeController = TextEditingController();
  final colorController = TextEditingController();
  final measurementsNoteController = TextEditingController();

  final fit = 'unisex'.obs;
  final cleaningPolicy = 'owner_cleans_after_return'.obs;
  final occasion = 'casual'.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    brandController.addListener(_updateCanContinue);
    sizeController.addListener(_updateCanContinue);
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value =
        brandController.text.trim().isNotEmpty &&
        sizeController.text.trim().isNotEmpty;
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  @override
  ClothingListingDetails toListingDetails() {
    return ClothingListingDetails(
      brand: brandController.text.trim(),
      size: sizeController.text.trim(),
      fit: fit.value,
      color: colorController.text.trim(),
      cleaningPolicy: cleaningPolicy.value,
      measurementsNote: measurementsNoteController.text.trim(),
      occasion: occasion.value,
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final clothingDetails =
        details is ClothingListingDetails
            ? details
            : ClothingListingDetails.fromMap(details.toMap());
    brandController.text = clothingDetails.brand;
    sizeController.text = clothingDetails.size;
    colorController.text = clothingDetails.color;
    measurementsNoteController.text = clothingDetails.measurementsNote;
    fit.value = clothingDetails.fit;
    cleaningPolicy.value = clothingDetails.cleaningPolicy;
    occasion.value = clothingDetails.occasion;
    _updateCanContinue();
  }

  @override
  void onClose() {
    brandController
      ..removeListener(_updateCanContinue)
      ..dispose();
    sizeController
      ..removeListener(_updateCanContinue)
      ..dispose();
    colorController.dispose();
    measurementsNoteController.dispose();
    fit.close();
    cleaningPolicy.close();
    occasion.close();
    canContinue.close();
  }
}
