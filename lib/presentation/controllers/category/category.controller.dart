import 'dart:async';

import 'package:get/get.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/core/services/category.service.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find<CategoryController>();

  final RxList<LNDCategory> categories = <LNDCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<LNDCategory>>? _subscription;
  Future<void>? _bootstrapFuture;

  List<LNDCategory> get parentCategories =>
      categories.where((category) => category.isParent).toList(growable: false);

  List<LNDCategory> subcategoriesFor(String parentId) {
    return categories
        .where((category) => category.parentId == parentId)
        .toList(growable: false);
  }

  LNDCategory? findById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
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
      final fresh =
          await LNDCategoryService.refreshActiveCategoriesFromServer();
      categories.assignAll(fresh);
      bindActiveCategories();
    } catch (e, st) {
      errorMessage.value = 'Unable to load categories.';
      LNDLogger.e('Unable to refresh categories', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  void bindActiveCategories() {
    if (_subscription != null) return;
    _subscription = LNDCategoryService.watchActiveCategories().listen(
      (items) {
        categories.assignAll(items);
        errorMessage.value = '';
      },
      onError: (Object e, StackTrace st) {
        errorMessage.value = 'Unable to load categories.';
        LNDLogger.e('Category listener failed', error: e, stackTrace: st);
      },
    );
  }

  Future<void> _bootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      try {
        final cached = await LNDCategoryService.getCachedCategories();
        if (cached.isNotEmpty) categories.assignAll(cached);
      } catch (e, st) {
        LNDLogger.w('Cached categories unavailable: $e', stackTrace: st);
      }

      bindActiveCategories();

      if (categories.isEmpty) {
        final fresh =
            await LNDCategoryService.refreshActiveCategoriesFromServer();
        categories.assignAll(fresh);
      }
    } catch (e, st) {
      errorMessage.value = 'Unable to load categories.';
      LNDLogger.e('Category bootstrap failed', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    categories.close();
    isLoading.close();
    errorMessage.close();
    super.onClose();
  }
}
