import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/amenity.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class AmenityService {
  AmenityService._();

  static final CollectionReference<Map<String, dynamic>> _amenities =
      FirebaseFirestore.instance.collection(LNDCollections.amenities.name);

  static Query<Map<String, dynamic>> get _activeAmenitiesQuery =>
      _amenities.where('isActive', isEqualTo: true).orderBy('sortOrder');

  static Stream<List<Amenity>> watchActiveAmenities() {
    return _activeAmenitiesQuery.snapshots().map(_mapSnapshot);
  }

  static Future<List<Amenity>> getActiveAmenities() async {
    final snapshot = await _activeAmenitiesQuery.get();
    return _mapSnapshot(snapshot);
  }

  static Future<List<Amenity>> getCachedAmenities() async {
    final snapshot = await _activeAmenitiesQuery.get(
      const GetOptions(source: Source.cache),
    );
    return _mapSnapshot(snapshot);
  }

  static Future<List<Amenity>> refreshActiveAmenitiesFromServer() async {
    final snapshot = await _activeAmenitiesQuery.get(
      const GetOptions(source: Source.server),
    );
    return _mapSnapshot(snapshot);
  }

  static List<Amenity> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(Amenity.fromFirestore)
        .where((amenity) => amenity.id.isNotEmpty && amenity.label.isNotEmpty)
        .toList(growable: false);
  }
}
