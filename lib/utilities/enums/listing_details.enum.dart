import 'package:flutter/material.dart';

enum ListingDetailSchema {
  stay('stay'),
  space('space'),
  vehicle('vehicle'),
  tool('tool'),
  electronics('electronics'),
  partyEvent('party_event'),
  clothing('clothing'),
  genericAsset('generic_asset');

  const ListingDetailSchema(this.value);

  final String value;

  static ListingDetailSchema fromValue(String? value) {
    return ListingDetailSchema.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ListingDetailSchema.genericAsset,
    );
  }
}

enum ListingKind {
  stay('stay'),
  space('space'),
  vehicle('vehicle'),
  tool('tool'),
  electronics('electronics'),
  partyEvent('party_event'),
  clothing('clothing'),
  genericAsset('generic_asset');

  const ListingKind(this.value);

  final String value;
}

enum StayType {
  entirePlace('entire_place', 'Entire place', Icons.home_outlined),
  privateRoom('private_room', 'Private room', Icons.bed_outlined),
  sharedRoom('shared_room', 'Shared room', Icons.groups_2_outlined);

  const StayType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static StayType fromValue(String? value) {
    return StayType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => StayType.entirePlace,
    );
  }
}

enum VehicleTransmission {
  automatic('automatic', 'Automatic'),
  semiAutomatic('semi_automatic', 'Semi-automatic'),
  manual('manual', 'Manual');

  const VehicleTransmission(this.value, this.label);

  final String value;
  final String label;
}

enum VehicleFuelType {
  gasoline('gasoline', 'Gasoline'),
  diesel('diesel', 'Diesel'),
  hybrid('hybrid', 'Hybrid'),
  electric('electric', 'Electric'),
  other('other', 'Other');

  const VehicleFuelType(this.value, this.label);

  final String value;
  final String label;
}

enum ToolPowerSource {
  battery('battery', 'Battery'),
  corded('corded', 'Corded'),
  gas('gas', 'Gas'),
  manual('manual', 'Manual'),
  other('other', 'Other');

  const ToolPowerSource(this.value, this.label);

  final String value;
  final String label;
}

enum SkillLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced'),
  professional('professional', 'Professional');

  const SkillLevel(this.value, this.label);

  final String value;
  final String label;
}

enum IndoorOutdoor {
  indoor('indoor', 'Indoor'),
  outdoor('outdoor', 'Outdoor'),
  both('both', 'Both');

  const IndoorOutdoor(this.value, this.label);

  final String value;
  final String label;
}

enum ClothingFit {
  men('men', 'Men'),
  women('women', 'Women'),
  unisex('unisex', 'Unisex'),
  kids('kids', 'Kids');

  const ClothingFit(this.value, this.label);

  final String value;
  final String label;
}

enum ClothingSize {
  xxs('xxs', 'XXS'),
  xs('xs', 'XS'),
  small('s', 'S'),
  medium('m', 'M'),
  large('l', 'L'),
  xl('xl', 'XL'),
  xxl('xxl', 'XXL'),
  xxxl('xxxl', 'XXXL'),
  freeSize('free_size', 'Free size'),
  oneSize('one_size', 'One size');

  const ClothingSize(this.value, this.label);

  final String value;
  final String label;
}

enum CleaningPolicy {
  ownerCleansAfterReturn(
    'owner_cleans_after_return',
    'Owner cleans after return',
  ),
  renterCleansBeforeReturn(
    'renter_cleans_before_return',
    'Renter cleans before return',
  ),
  dryCleanOnly('dry_clean_only', 'Dry clean only');

  const CleaningPolicy(this.value, this.label);

  final String value;
  final String label;
}

enum ClothingOccasion {
  casual('casual', 'Casual'),
  formal('formal', 'Formal'),
  costume('costume', 'Costume'),
  sports('sports', 'Sports');

  const ClothingOccasion(this.value, this.label);

  final String value;
  final String label;
}
