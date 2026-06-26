import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class VehicleListingDetails extends ListingDetailsData {
  final String make;
  final String model;
  final int? year;
  final String transmission;
  final String fuelType;
  final int? seats;
  final int? mileageLimitKmPerDay;
  final bool licenseRequired;
  final bool helmetIncluded;
  final bool deliveryAvailable;

  const VehicleListingDetails({
    this.make = '',
    this.model = '',
    this.year,
    this.transmission = 'automatic',
    this.fuelType = 'gasoline',
    this.seats,
    this.mileageLimitKmPerDay,
    this.licenseRequired = true,
    this.helmetIncluded = false,
    this.deliveryAvailable = false,
  });

  @override
  String get detailSchemaKey => 'vehicle';

  factory VehicleListingDetails.fromMap(Map<String, dynamic> map) {
    return VehicleListingDetails(
      make: listingDetailString(map['make']),
      model: listingDetailString(map['model']),
      year: listingDetailInt(map['year']),
      transmission: listingDetailString(
        map['transmission'],
        fallback: 'automatic',
      ),
      fuelType: listingDetailString(map['fuelType'], fallback: 'gasoline'),
      seats: listingDetailInt(map['seats']),
      mileageLimitKmPerDay: listingDetailInt(map['mileageLimitKmPerDay']),
      licenseRequired: map['licenseRequired'] != false,
      helmetIncluded: map['helmetIncluded'] == true,
      deliveryAvailable: map['deliveryAvailable'] == true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'mileageLimitKmPerDay': mileageLimitKmPerDay,
      'licenseRequired': licenseRequired,
      'helmetIncluded': helmetIncluded,
      'deliveryAvailable': deliveryAvailable,
    }..removeWhere((key, value) => value == null);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleListingDetails &&
        other.make == make &&
        other.model == model &&
        other.year == year &&
        other.transmission == transmission &&
        other.fuelType == fuelType &&
        other.seats == seats &&
        other.mileageLimitKmPerDay == mileageLimitKmPerDay &&
        other.licenseRequired == licenseRequired &&
        other.helmetIncluded == helmetIncluded &&
        other.deliveryAvailable == deliveryAvailable;
  }

  @override
  int get hashCode => Object.hash(
    make,
    model,
    year,
    transmission,
    fuelType,
    seats,
    mileageLimitKmPerDay,
    licenseRequired,
    helmetIncluded,
    deliveryAvailable,
  );
}
