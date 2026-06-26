import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingStayDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'stay';

  final maxGuestsController = TextEditingController(text: '1');
  final bedroomsController = TextEditingController(text: '1');
  final bedsController = TextEditingController(text: '1');
  final bathroomsController = TextEditingController(text: '1');
  final minimumNightsController = TextEditingController(text: '1');
  final amenityController = TextEditingController();

  final stayType = 'entire_place'.obs;
  final checkInTime = '14:00'.obs;
  final checkOutTime = '11:00'.obs;
  final amenities = <String>[].obs;
  final petsAllowed = false.obs;
  final smokingAllowed = false.obs;
  final partiesAllowed = false.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    for (final controller in _requiredControllers) {
      controller.addListener(_updateCanContinue);
    }
    _updateCanContinue();
  }

  List<TextEditingController> get _requiredControllers => [
    maxGuestsController,
    bedroomsController,
    bedsController,
    bathroomsController,
    minimumNightsController,
  ];

  void _updateCanContinue() {
    canContinue.value = _requiredControllers.every(_hasPositiveInt);
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  int? _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim());
  }

  bool _hasPositiveInt(TextEditingController controller) {
    return (_parseInt(controller) ?? 0) >= 1;
  }

  String _positiveIntString(dynamic value, {int fallback = 1}) {
    final parsed = int.tryParse(
      value?.toString().replaceAll(',', '').trim() ?? '',
    );
    return (parsed != null && parsed >= 1 ? parsed : fallback).toString();
  }

  @override
  StayListingDetails toListingDetails() {
    return StayListingDetails(
      stayType: stayType.value,
      maxGuests: _parseInt(maxGuestsController),
      bedrooms: _parseInt(bedroomsController),
      beds: _parseInt(bedsController),
      bathrooms: _parseInt(bathroomsController),
      amenities: amenities.toList(),
      checkInTime: checkInTime.value,
      checkOutTime: checkOutTime.value,
      minimumNights: _parseInt(minimumNightsController),
      petsAllowed: petsAllowed.value,
      smokingAllowed: smokingAllowed.value,
      partiesAllowed: partiesAllowed.value,
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final stayDetails =
        details is StayListingDetails
            ? details
            : StayListingDetails.fromMap(details.toMap());
    stayType.value = stayDetails.stayType;
    maxGuestsController.text = _positiveIntString(stayDetails.maxGuests);
    bedroomsController.text = _positiveIntString(stayDetails.bedrooms);
    bedsController.text = _positiveIntString(stayDetails.beds);
    bathroomsController.text = _positiveIntString(stayDetails.bathrooms);
    minimumNightsController.text = _positiveIntString(
      stayDetails.minimumNights,
    );
    checkInTime.value = stayDetails.checkInTime;
    checkOutTime.value = stayDetails.checkOutTime;
    amenities.assignAll(stayDetails.amenities);
    petsAllowed.value = stayDetails.petsAllowed;
    smokingAllowed.value = stayDetails.smokingAllowed;
    partiesAllowed.value = stayDetails.partiesAllowed;
    _updateCanContinue();
  }

  @override
  void onClose() {
    for (final controller in _requiredControllers) {
      controller
        ..removeListener(_updateCanContinue)
        ..dispose();
    }
    amenityController.dispose();
    stayType.close();
    checkInTime.close();
    checkOutTime.close();
    amenities.close();
    petsAllowed.close();
    smokingAllowed.close();
    partiesAllowed.close();
    canContinue.close();
  }
}
