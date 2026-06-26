import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingSpaceDetailsChunk
    implements CreateListingDynamicDetailsChunk {
  @override
  final formKey = GlobalKey<FormState>();

  @override
  String get detailSchemaKey => 'space';

  final capacityController = TextEditingController(text: '1');
  final setupTimeMinutesController = TextEditingController();
  final cleanupTimeMinutesController = TextEditingController();
  final operatingHoursStartTimeController = TextEditingController();
  final operatingHoursEndTimeController = TextEditingController();
  final noiseRestrictionsStartTimeController = TextEditingController();
  final noiseRestrictionsEndTimeController = TextEditingController();
  final allowedUseController = TextEditingController();
  final amenityController = TextEditingController();

  final operatingHoursEnabled = ValueNotifier(false);
  final noiseRestrictionsEnabled = ValueNotifier(false);
  final allowedUses = <String>[].obs;
  final amenities = <String>[].obs;
  final hasParking = false.obs;
  @override
  final canContinue = false.obs;

  @override
  void onInit() {
    capacityController.addListener(_updateCanContinue);
    _updateCanContinue();
  }

  void _updateCanContinue() {
    canContinue.value = (_parseInt(capacityController) ?? 0) >= 1;
  }

  @override
  bool validate() => formKey.currentState?.validate() != false;

  int? _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.replaceAll(',', '').trim());
  }

  String _positiveIntString(dynamic value, {int fallback = 1}) {
    final parsed = int.tryParse(
      value?.toString().replaceAll(',', '').trim() ?? '',
    );
    return (parsed != null && parsed >= 1 ? parsed : fallback).toString();
  }

  @override
  SpaceListingDetails toListingDetails() {
    final operatingHours = _timeRange(
      operatingHoursEnabled,
      operatingHoursStartTimeController,
      operatingHoursEndTimeController,
    );
    final noiseRestrictions = _timeRange(
      noiseRestrictionsEnabled,
      noiseRestrictionsStartTimeController,
      noiseRestrictionsEndTimeController,
    );

    return SpaceListingDetails(
      capacity: _parseInt(capacityController),
      allowedUses: allowedUses.toList(),
      amenities: amenities.toList(),
      hasParking: hasParking.value,
      setupTimeMinutes: _parseInt(setupTimeMinutesController),
      cleanupTimeMinutes: _parseInt(cleanupTimeMinutesController),
      operatingHours: operatingHours,
      noiseRestrictions: noiseRestrictions,
    );
  }

  @override
  void populateFromDetails(ListingDetailsData details) {
    final spaceDetails =
        details is SpaceListingDetails
            ? details
            : SpaceListingDetails.fromMap(details.toMap());
    capacityController.text = _positiveIntString(spaceDetails.capacity);
    setupTimeMinutesController.text =
        spaceDetails.setupTimeMinutes?.toString() ?? '';
    cleanupTimeMinutesController.text =
        spaceDetails.cleanupTimeMinutes?.toString() ?? '';
    _populateTimeRange(
      spaceDetails.operatingHours,
      operatingHoursEnabled,
      operatingHoursStartTimeController,
      operatingHoursEndTimeController,
    );
    _populateTimeRange(
      spaceDetails.noiseRestrictions,
      noiseRestrictionsEnabled,
      noiseRestrictionsStartTimeController,
      noiseRestrictionsEndTimeController,
    );
    allowedUses.assignAll(spaceDetails.allowedUses);
    amenities.assignAll(spaceDetails.amenities);
    hasParking.value = spaceDetails.hasParking;
    _updateCanContinue();
  }

  ListingTimeRange? _timeRange(
    ValueNotifier<bool> enabledNotifier,
    TextEditingController startController,
    TextEditingController endController,
  ) {
    final enabled = enabledNotifier.value;
    final startTime = startController.text.trim();
    final endTime = endController.text.trim();
    if (!enabled) {
      return const ListingTimeRange(enabled: false);
    }

    return ListingTimeRange(
      enabled: true,
      startTime: startTime,
      endTime: endTime,
    );
  }

  void _populateTimeRange(
    ListingTimeRange? value,
    ValueNotifier<bool> enabledNotifier,
    TextEditingController startController,
    TextEditingController endController,
  ) {
    if (value == null) {
      enabledNotifier.value = false;
      startController.text = '';
      endController.text = '';
      return;
    }

    enabledNotifier.value = value.enabled;
    startController.text = value.startTime;
    endController.text = value.endTime;
    if (!enabledNotifier.value) {
      startController.text = '';
      endController.text = '';
    }
  }

  @override
  void onClose() {
    capacityController
      ..removeListener(_updateCanContinue)
      ..dispose();
    setupTimeMinutesController.dispose();
    cleanupTimeMinutesController.dispose();
    operatingHoursStartTimeController.dispose();
    operatingHoursEndTimeController.dispose();
    noiseRestrictionsStartTimeController.dispose();
    noiseRestrictionsEndTimeController.dispose();
    operatingHoursEnabled.dispose();
    noiseRestrictionsEnabled.dispose();
    allowedUseController.dispose();
    amenityController.dispose();
    allowedUses.close();
    amenities.close();
    hasParking.close();
    canContinue.close();
  }
}
