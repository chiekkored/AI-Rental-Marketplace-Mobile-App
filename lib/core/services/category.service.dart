import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class LNDCategoryService {
  LNDCategoryService._();

  static final CollectionReference<Map<String, dynamic>> _categories =
      FirebaseFirestore.instance.collection(LNDCollections.categories.name);

  static Query<Map<String, dynamic>> get _activeCategoriesQuery =>
      _categories.where('isActive', isEqualTo: true).orderBy('sortOrder');

  static Stream<List<LNDCategory>> watchActiveCategories() {
    return _activeCategoriesQuery.snapshots().map(_mapSnapshot);
  }

  static Future<List<LNDCategory>> getActiveCategories() async {
    final snapshot = await _activeCategoriesQuery.get();
    return _mapSnapshot(snapshot);
  }

  static Future<List<LNDCategory>> getCachedCategories() async {
    final snapshot = await _activeCategoriesQuery.get(
      const GetOptions(source: Source.cache),
    );
    return _mapSnapshot(snapshot);
  }

  static Future<List<LNDCategory>> refreshActiveCategoriesFromServer() async {
    final snapshot = await _activeCategoriesQuery.get(
      const GetOptions(source: Source.server),
    );
    return _mapSnapshot(snapshot);
  }

  static List<LNDCategory> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(LNDCategory.fromFirestore)
        .where((category) => category.id.isNotEmpty && category.name.isNotEmpty)
        .toList(growable: false);
  }
}
