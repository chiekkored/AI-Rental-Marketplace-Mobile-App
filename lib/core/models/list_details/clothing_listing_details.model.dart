import 'package:lend/core/models/list_details/listing_details_data.model.dart';
import 'package:lend/core/models/list_details/listing_details_parsers.dart';

class ClothingListingDetails extends ListingDetailsData {
  final String brand;
  final String size;
  final String fit;
  final String color;
  final String cleaningPolicy;
  final String measurementsNote;
  final String occasion;

  const ClothingListingDetails({
    this.brand = '',
    this.size = '',
    this.fit = 'unisex',
    this.color = '',
    this.cleaningPolicy = 'owner_cleans_after_return',
    this.measurementsNote = '',
    this.occasion = 'casual',
  });

  @override
  String get detailSchemaKey => 'clothing';

  factory ClothingListingDetails.fromMap(Map<String, dynamic> map) {
    return ClothingListingDetails(
      brand: listingDetailString(map['brand']),
      size: listingDetailString(map['size']),
      fit: listingDetailString(map['fit'], fallback: 'unisex'),
      color: listingDetailString(map['color']),
      cleaningPolicy: listingDetailString(
        map['cleaningPolicy'],
        fallback: 'owner_cleans_after_return',
      ),
      measurementsNote: listingDetailString(map['measurementsNote']),
      occasion: listingDetailString(map['occasion'], fallback: 'casual'),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'size': size,
      'fit': fit,
      'color': color,
      'cleaningPolicy': cleaningPolicy,
      'measurementsNote': measurementsNote,
      'occasion': occasion,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ClothingListingDetails &&
        other.brand == brand &&
        other.size == size &&
        other.fit == fit &&
        other.color == color &&
        other.cleaningPolicy == cleaningPolicy &&
        other.measurementsNote == measurementsNote &&
        other.occasion == occasion;
  }

  @override
  int get hashCode => Object.hash(
    brand,
    size,
    fit,
    color,
    cleaningPolicy,
    measurementsNote,
    occasion,
  );
}
