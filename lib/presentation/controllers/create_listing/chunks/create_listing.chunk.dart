import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';

abstract class CreateListingChunk {
  void onInit() {}
  void onClose() {}
}

abstract class CreateListingFormChunk extends CreateListingChunk {
  bool validate();

  Map<String, dynamic> toMap();
}

abstract class CreateListingDynamicDetailsChunk extends CreateListingChunk {
  GlobalKey<FormState> get formKey;

  String get detailSchemaKey;

  RxBool get canContinue;

  bool validate();

  ListingDetailsData toListingDetails();

  void populateFromDetails(ListingDetailsData details);
}
