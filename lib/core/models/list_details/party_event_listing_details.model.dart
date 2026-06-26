import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class PartyEventListingDetails extends ListingDetailsData {
  final int? quantity;
  final String setSize;
  final bool setupRequired;
  final bool deliveryRequired;
  final bool powerRequired;
  final String indoorOutdoor;
  final String setupInstructions;

  const PartyEventListingDetails({
    this.quantity,
    this.setSize = '',
    this.setupRequired = false,
    this.deliveryRequired = false,
    this.powerRequired = false,
    this.indoorOutdoor = 'both',
    this.setupInstructions = '',
  });

  @override
  String get detailSchemaKey => 'party_event';

  factory PartyEventListingDetails.fromMap(Map<String, dynamic> map) {
    return PartyEventListingDetails(
      quantity: listingDetailInt(map['quantity']),
      setSize: listingDetailString(map['setSize']),
      setupRequired: map['setupRequired'] == true,
      deliveryRequired: map['deliveryRequired'] == true,
      powerRequired: map['powerRequired'] == true,
      indoorOutdoor: listingDetailString(
        map['indoorOutdoor'],
        fallback: 'both',
      ),
      setupInstructions: listingDetailString(map['setupInstructions']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'setSize': setSize,
      'setupRequired': setupRequired,
      'deliveryRequired': deliveryRequired,
      'powerRequired': powerRequired,
      'indoorOutdoor': indoorOutdoor,
      'setupInstructions': setupInstructions,
    }..removeWhere((key, value) => value == null);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyEventListingDetails &&
        other.quantity == quantity &&
        other.setSize == setSize &&
        other.setupRequired == setupRequired &&
        other.deliveryRequired == deliveryRequired &&
        other.powerRequired == powerRequired &&
        other.indoorOutdoor == indoorOutdoor &&
        other.setupInstructions == setupInstructions;
  }

  @override
  int get hashCode => Object.hash(
    quantity,
    setSize,
    setupRequired,
    deliveryRequired,
    powerRequired,
    indoorOutdoor,
    setupInstructions,
  );
}
