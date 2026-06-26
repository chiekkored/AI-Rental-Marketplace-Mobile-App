import 'dart:async';

import 'package:get/get.dart';
import 'package:lend/core/models/amenity.model.dart';
import 'package:lend/core/services/amenity.service.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class AmenityController extends GetxController {
  static AmenityController get instance => Get.find<AmenityController>();

  final RxList<Amenity> amenities = <Amenity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<Amenity>>? _subscription;
  Future<void>? _bootstrapFuture;

  List<Amenity> amenitiesForDetailSchemaKey(String detailSchemaKey) {
    return amenities
        .where((amenity) => amenity.appliesToDetailSchemaKey(detailSchemaKey))
        .toList(growable: false);
  }

  Amenity? findById(String id) {
    for (final amenity in amenities) {
      if (amenity.id == id) return amenity;
    }
    return null;
  }

  Future<void> bootstrap() {
    return _bootstrapFuture ??= _bootstrap();
  }

  // ignore: annotate_overrides
  Future<void> refresh() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fresh = await AmenityService.refreshActiveAmenitiesFromServer();
      amenities.assignAll(fresh);
      bindActiveAmenities();
    } catch (e, st) {
      errorMessage.value = 'Unable to load amenities.';
      LNDLogger.e('Unable to refresh amenities', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  void bindActiveAmenities() {
    if (_subscription != null) return;
    _subscription = AmenityService.watchActiveAmenities().listen(
      (items) {
        amenities.assignAll(items);
        errorMessage.value = '';
      },
      onError: (Object e, StackTrace st) {
        errorMessage.value = 'Unable to load amenities.';
        LNDLogger.e('Amenity listener failed', error: e, stackTrace: st);
      },
    );
  }

  Future<void> _bootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      try {
        final cached = await AmenityService.getCachedAmenities();
        if (cached.isNotEmpty) amenities.assignAll(cached);
      } catch (e, st) {
        LNDLogger.w('Cached amenities unavailable: $e', stackTrace: st);
      }

      bindActiveAmenities();

      if (amenities.isEmpty) {
        final fresh = await AmenityService.refreshActiveAmenitiesFromServer();
        amenities.assignAll(fresh);
      }
    } catch (e, st) {
      errorMessage.value = 'Unable to load amenities.';
      LNDLogger.e('Amenity bootstrap failed', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    amenities.close();
    isLoading.close();
    errorMessage.close();
    super.onClose();
  }
}
