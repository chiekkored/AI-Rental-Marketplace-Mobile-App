import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/list_details/list_details.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/presentation/pages/asset/widgets/details/clothing_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_section_shell.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/electronics_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/generic_asset_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/party_event_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/space_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/stay_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/tool_details.widget.dart';
import 'package:lend/presentation/pages/asset/widgets/details/vehicle_details.widget.dart';

class AssetListingDetails extends GetView<AssetController> {
  const AssetListingDetails({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final listingDetails = controller.asset?.listingDetails;
        final details = listingDetails?.details;
        if (listingDetails == null || details == null || details.isEmpty) {
          return const SizedBox.shrink();
        }

        final child = switch (details) {
          StayListingDetails() => StayAssetDetails(details: details),
          SpaceListingDetails() => SpaceAssetDetails(details: details),
          VehicleListingDetails() => VehicleAssetDetails(details: details),
          ToolListingDetails() => ToolAssetDetails(details: details),
          ElectronicsListingDetails() => ElectronicsAssetDetails(
            details: details,
          ),
          PartyEventListingDetails() => PartyEventAssetDetails(
            details: details,
          ),
          ClothingListingDetails() => ClothingAssetDetails(details: details),
          GenericAssetListingDetails() => GenericAssetDetails(details: details),
          _ => const SizedBox.shrink(),
        };

        return AssetDetailSectionShell(
          title: _sectionTitle(listingDetails.detailSchemaKey),
          children: [child],
        );
      }),
    );
  }
}

String _sectionTitle(String detailSchemaKey) {
  return switch (detailSchemaKey) {
    'stay' => 'About this stay',
    'space' => 'About this space',
    'vehicle' => 'About this vehicle',
    'tool' => 'About this tool',
    'electronics' => 'About this device',
    'party_event' => 'About this event item',
    'clothing' => 'About this item',
    _ => 'Listing details',
  };
}
