import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/asset_search_filter.model.dart';
import 'package:lend/core/models/asset_search_result.model.dart';
import 'package:lend/core/services/algolia_search.service.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/user_block/user_block.controller.dart';
import 'package:lend/presentation/pages/search/widgets/search_filter_sheet.widget.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/currency.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class AssetSearchController extends GetxController {
  static AssetSearchController get instance =>
      Get.find<AssetSearchController>();
  static const int maxHistoryItems = 10;
  static List<AssetSearchPriceRange> get priceRanges {
    final currencyCode = activeSearchCurrencyCode;
    return [
      const AssetSearchPriceRange(label: 'Any price'),
      AssetSearchPriceRange(
        label: 'Under $currencyCode 500',
        maxDailyRate: 500,
      ),
      AssetSearchPriceRange(
        label: '$currencyCode 500 - $currencyCode 1,500',
        minDailyRate: 500,
        maxDailyRate: 1500,
      ),
      AssetSearchPriceRange(
        label: '$currencyCode 1,500 - $currencyCode 3,000',
        minDailyRate: 1500,
        maxDailyRate: 3000,
      ),
      AssetSearchPriceRange(label: '$currencyCode 3,000+', minDailyRate: 3000),
    ];
  }

  final searchController = TextEditingController();

  final RxList<String> _searchHistory = <String>[].obs;
  final RxList<AssetSearchResult> _results = <AssetSearchResult>[].obs;
  final RxList<AssetSearchFacetOption> _categoryFacets =
      <AssetSearchFacetOption>[].obs;
  final RxList<String> _selectedCategories = <String>[].obs;
  final Rxn<AssetSearchPriceRange> _selectedPriceRange =
      Rxn<AssetSearchPriceRange>();
  final RxBool _isLoading = false.obs;
  final RxString _submittedQuery = ''.obs;

  List<String> get searchHistory => _searchHistory;
  List<AssetSearchResult> get results => _results;
  List<AssetSearchFacetOption> get categoryFacets => _categoryFacets;
  List<String> get selectedCategories => _selectedCategories;
  AssetSearchPriceRange? get selectedPriceRange => _selectedPriceRange.value;
  bool get isLoading => _isLoading.value;
  String get submittedQuery => _submittedQuery.value;
  bool get hasSubmittedQuery => submittedQuery.trim().isNotEmpty;
  bool get hasActivePriceFilter => selectedPriceRange?.hasBounds ?? false;
  String get activeCurrencyCode => activeSearchCurrencyCode;
  bool get hasCurrencyMismatch =>
      Get.isRegistered<HomeController>() &&
      HomeController.instance.hasCurrencyMismatch;
  String get selectedCurrencyCode => LNDCurrency.selectedDisplayCurrency();
  static String get activeSearchCurrencyCode {
    if (Get.isRegistered<HomeController>()) {
      return HomeController.instance.activeLocationCurrencyCode;
    }
    return LNDCurrency.selectedDisplayCurrency();
  }

  int get activeFilterCount =>
      _selectedCategories.length + (hasActivePriceFilter ? 1 : 0);

  @override
  void onReady() {
    _loadSearchHistory();

    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchHistory.close();
    _results.close();
    _categoryFacets.close();
    _selectedCategories.close();
    _selectedPriceRange.close();
    _isLoading.close();
    _submittedQuery.close();
    super.onClose();
  }

  Future<void> submitSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    await _saveSearchQuery(query);
    _submittedQuery.value = query;
    _isLoading.value = true;

    try {
      final response = await LNDAlgoliaSearchService.searchAssets(
        query,
        filters: _currentFilters(),
      );
      _results.assignAll(
        response.results.where(
          (asset) => !UserBlockController.instance.isExcluded(asset.ownerId),
        ),
      );
      _categoryFacets.assignAll(response.categoryFacets);
    } catch (e, st) {
      _results.clear();
      LNDLogger.e('Error searching assets', error: e, stackTrace: st);
      LNDSnackbar.showError(
        LNDAlgoliaSearchService.isConfigured
            ? 'Unable to search right now.'
            : 'Algolia search is not configured.',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> showFilters() async {
    if (!hasSubmittedQuery) return;

    await LNDShow.bottomSheet(const SearchFilterSheet(), expand: false);
  }

  Future<void> applyFilters({
    required List<String> categories,
    required AssetSearchPriceRange? priceRange,
  }) async {
    _selectedCategories.assignAll(
      categories
          .map((category) => category.trim())
          .where((category) => category.isNotEmpty)
          .toSet(),
    );
    _selectedPriceRange.value =
        priceRange?.hasBounds == true ? priceRange : null;

    if (hasSubmittedQuery) {
      await submitSearch(submittedQuery);
    }
  }

  Future<void> selectCategoryFacet(String? category) async {
    final trimmedCategory = category?.trim();
    if (trimmedCategory == null || trimmedCategory.isEmpty) {
      _selectedCategories.clear();
    } else {
      _selectedCategories.assignAll([trimmedCategory]);
    }

    if (hasSubmittedQuery) {
      await submitSearch(submittedQuery);
    }
  }

  Future<void> resetFilters() async {
    _selectedCategories.clear();
    _selectedPriceRange.value = null;

    if (hasSubmittedQuery) {
      await submitSearch(submittedQuery);
    }
  }

  void selectHistoryItem(String query) {
    searchController.text = query;
    searchController.selection = TextSelection.collapsed(
      offset: searchController.text.length,
    );
  }

  void clearSearch() {
    searchController.clear();
    _submittedQuery.value = '';
    _results.clear();
    _categoryFacets.clear();
    _selectedCategories.clear();
    _selectedPriceRange.value = null;
  }

  void removeExcludedOwners(Set<String> ownerIds) {
    _results.removeWhere((asset) => ownerIds.contains(asset.ownerId));
  }

  void openAsset(AssetSearchResult result) {
    LNDNavigate.toAssetPage(args: Asset(id: result.id));
  }

  void _loadSearchHistory() {
    final rawHistory = LNDStorageService.readList(
      LNDStorageConstants.searchHistory,
    );

    _searchHistory.assignAll(rawHistory?.whereType<String>() ?? []);
  }

  Future<void> _saveSearchQuery(String query) async {
    final nextHistory = buildNextSearchHistory(
      currentHistory: _searchHistory,
      query: query,
      limit: maxHistoryItems,
    );

    _searchHistory.value = nextHistory;
    await LNDStorageService.writeList(
      LNDStorageConstants.searchHistory,
      nextHistory,
    );
  }

  AssetSearchFilters _currentFilters() {
    return AssetSearchFilters(
      categoryIds: _selectedCategories.toList(growable: false),
      priceRange: selectedPriceRange,
      currencyCode: activeCurrencyCode,
    );
  }

  static List<String> buildNextSearchHistory({
    required Iterable<String> currentHistory,
    required String query,
    int limit = maxHistoryItems,
  }) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return currentHistory.toList(growable: false);
    }

    final dedupedHistory = currentHistory.where(
      (item) => item.trim().toLowerCase() != trimmedQuery.toLowerCase(),
    );

    return [
      trimmedQuery,
      ...dedupedHistory,
    ].take(limit).toList(growable: false);
  }
}
