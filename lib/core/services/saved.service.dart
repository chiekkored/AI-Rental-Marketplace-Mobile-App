import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/simple_asset.model.dart';
import 'package:lend/core/services/recommendation.service.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/utilities/constants/collections.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class LNDSavedService {
  static final _db = FirebaseFirestore.instance;

  static Future<Either<List<SimpleAsset>, String>> getUserSavedAssets() async {
    try {
      final userSavedDocs =
          await _db
              .collection(LNDCollections.users.name)
              .doc(AuthController.instance.uid)
              .collection(LNDCollections.saved.name)
              .get();

      final savedAssets =
          userSavedDocs.docs
              .map((doc) => SimpleAsset.fromMap(doc.data()))
              .toList();

      return Left(savedAssets);
    } catch (e) {
      LNDLogger.e(e.toString(), error: e, stackTrace: StackTrace.current);
      return Right(e.toString());
    }
  }

  static Future<Either<bool, String>> saveUserAsset(Asset asset) async {
    try {
      final userSavedRef = _db
          .collection(LNDCollections.users.name)
          .doc(AuthController.instance.uid)
          .collection(LNDCollections.saved.name)
          .doc(asset.id);

      await userSavedRef.set(
        SimpleAsset(
          id: asset.id,
          owner: asset.owner,
          title: asset.title,
          images: asset.images,
          categoryId: asset.categoryId,
          categoryName: asset.categoryName,
          subcategoryId: asset.subcategoryId,
          subcategoryName: asset.subcategoryName,
          rates: asset.rates,
          createdAt: asset.createdAt,
          status: asset.status,
          location: asset.location,
        ).toMap(),
      );
      await LNDRecommendationService.recordSavedAsset(assetId: asset.id);

      return const Left(true);
    } catch (e) {
      LNDLogger.e(e.toString(), error: e, stackTrace: StackTrace.current);
      return Right(e.toString());
    }
  }

  static Future<Either<bool, String>> removeSavedUserAsset(
    String assetId,
  ) async {
    try {
      final userSavedRef = _db
          .collection(LNDCollections.users.name)
          .doc(AuthController.instance.uid)
          .collection(LNDCollections.saved.name);

      await userSavedRef.doc(assetId).delete();

      return const Left(true);
    } catch (e) {
      LNDLogger.e(e.toString(), error: e, stackTrace: StackTrace.current);
      return Right(e.toString());
    }
  }
}
