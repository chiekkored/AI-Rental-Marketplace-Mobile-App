import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/presentation/controllers/category/category.controller.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';

class CreateListingCategoryChunk implements CreateListingChunk {
  final categoryController = TextEditingController();

  final RxBool canContinue = false.obs;
  final Rxn<LNDCategory> selectedCategory = Rxn<LNDCategory>();
  final Rxn<LNDCategory> selectedSubcategory = Rxn<LNDCategory>();

  final List<Worker> _workers = [];

  @override
  void onInit() {
    _workers.addAll([
      ever<LNDCategory?>(selectedCategory, (_) => _updateCanContinue()),
      ever<LNDCategory?>(selectedSubcategory, (_) => _updateCanContinue()),
    ]);

    _updateCanContinue();
  }

  bool get hasSelectedCategory => selectedCategory.value != null;

  bool get hasSelectedSubcategory => selectedSubcategory.value != null;

  List<LNDCategory> get availableSubcategories {
    final parentId = selectedCategory.value?.id;
    if (parentId == null || parentId.isEmpty) return const [];
    return CategoryController.instance.subcategoriesFor(parentId);
  }

  bool get requiresSubcategory => availableSubcategories.isNotEmpty;

  LNDCategory? get selectedSchemaSource =>
      selectedSubcategory.value ?? selectedCategory.value;

  String get categoryId => selectedCategory.value?.id ?? '';

  String get categoryName => selectedCategory.value?.name ?? '';

  String? get subcategoryId => selectedSubcategory.value?.id;

  String? get subcategoryName => selectedSubcategory.value?.name;

  String get listingKind => selectedSchemaSource?.listingKind ?? '';

  String get detailSchemaKey => selectedSchemaSource?.detailSchemaKey ?? '';

  void selectCategory(LNDCategory category) {
    selectedCategory.value = category;
    selectedSubcategory.value = null;
    categoryController.text = category.name;
    _updateCanContinue();
  }

  void selectSubcategory(LNDCategory category) {
    selectedSubcategory.value = category;
    _updateCanContinue();
  }

  void populateFromAsset(Asset asset) {
    categoryController.text = asset.categoryName ?? '';
    selectedCategory.value = CategoryController.instance.findById(
      asset.categoryId ?? '',
    );
    selectedSubcategory.value =
        asset.subcategoryId == null
            ? null
            : CategoryController.instance.findById(asset.subcategoryId!);
    _updateCanContinue();
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    final categoryId = draft['categoryId'] as String?;
    final subcategoryId = draft['subcategoryId'] as String?;

    selectedCategory.value =
        categoryId == null
            ? null
            : CategoryController.instance.findById(categoryId);
    selectedSubcategory.value =
        subcategoryId == null
            ? null
            : CategoryController.instance.findById(subcategoryId);

    categoryController.text =
        selectedCategory.value?.name ?? draft['categoryName'] as String? ?? '';
    _updateCanContinue();
  }

  Map<String, dynamic> toDraftMap() {
    return toMap();
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'listingKind': listingKind,
      'detailSchemaKey': detailSchemaKey,
    };
  }

  void _updateCanContinue() {
    canContinue.value = selectedCategory.value != null;
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }

    canContinue.close();
    selectedCategory.close();
    selectedSubcategory.close();
    categoryController.dispose();
  }
}
