import 'package:lend/core/models/asset_search_result.model.dart';

class AssetSearchFacetOption {
  const AssetSearchFacetOption({required this.value, required this.count});

  final String value;
  final int count;
}

class AssetSearchPriceRange {
  const AssetSearchPriceRange({
    required this.label,
    this.minDailyRate,
    this.maxDailyRate,
  });

  final String label;
  final int? minDailyRate;
  final int? maxDailyRate;

  bool get hasBounds => minDailyRate != null || maxDailyRate != null;

  @override
  bool operator ==(covariant AssetSearchPriceRange other) {
    if (identical(this, other)) return true;
    return other.label == label &&
        other.minDailyRate == minDailyRate &&
        other.maxDailyRate == maxDailyRate;
  }

  @override
  int get hashCode =>
      label.hashCode ^ minDailyRate.hashCode ^ maxDailyRate.hashCode;
}

class AssetSearchFilters {
  const AssetSearchFilters({
    this.categoryIds = const [],
    this.priceRange,
    this.currencyCode,
  });

  final List<String> categoryIds;
  final AssetSearchPriceRange? priceRange;
  final String? currencyCode;

  bool get hasActiveFilters =>
      categoryIds.isNotEmpty ||
      (priceRange?.hasBounds ?? false) ||
      currencyCode?.trim().isNotEmpty == true;
}

class AssetSearchResponse {
  const AssetSearchResponse({
    required this.results,
    required this.categoryFacets,
  });

  final List<AssetSearchResult> results;
  final List<AssetSearchFacetOption> categoryFacets;
}
