import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lend/core/models/asset_search_filter.model.dart';
import 'package:lend/core/models/asset_search_result.model.dart';
import 'package:lend/utilities/enums/availability.enum.dart';

class LNDAlgoliaSearchService {
  LNDAlgoliaSearchService._();

  static SearchClient? _client;

  static String get _applicationId =>
      dotenv.env['ALGOLIA_APPLICATION_ID']?.trim() ?? '';
  static String get _searchApiKey =>
      dotenv.env['ALGOLIA_SEARCH_API_KEY']?.trim() ?? '';
  static String get _assetsIndexName =>
      dotenv.env['ALGOLIA_ASSETS_INDEX_NAME']?.trim() ?? '';

  static bool get isConfigured =>
      _applicationId.isNotEmpty &&
      _searchApiKey.isNotEmpty &&
      _assetsIndexName.isNotEmpty;

  static Future<AssetSearchResponse> searchAssets(
    String query, {
    AssetSearchFilters filters = const AssetSearchFilters(),
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const AssetSearchResponse(results: [], categoryFacets: []);
    }

    final client = _searchClient();
    final numericFilters = buildNumericFilters(filters.priceRange);
    final response = await client.searchIndex(
      request: _searchRequest(
        query: trimmedQuery,
        hitsPerPage: 20,
        facetFilters: buildFacetFilters(
          filters.categoryIds,
          currencyCode: filters.currencyCode,
        ),
        numericFilters: numericFilters,
        attributesToRetrieve: const [
          'id',
          'objectID',
          'title',
          'categoryId',
          'categoryName',
          'subcategoryId',
          'subcategoryName',
          'images',
          'rates',
          'status',
          'isDeleted',
          'averageRating',
          'reviewCount',
          'ownerId',
        ],
      ),
    );
    final facetResponse = await client.searchIndex(
      request: _searchRequest(
        query: trimmedQuery,
        hitsPerPage: 0,
        facetFilters: buildFacetFilters(
          const [],
          currencyCode: filters.currencyCode,
        ),
        numericFilters: numericFilters,
        attributesToRetrieve: const ['categoryId'],
      ),
    );

    return AssetSearchResponse(
      results: response.hits
          .map(AssetSearchResult.fromAlgoliaHit)
          .where(
            (asset) =>
                asset.id.isNotEmpty &&
                !asset.isDeleted &&
                (asset.status == Availability.available.label ||
                    asset.status == Availability.underMaintenance.label),
          )
          .toList(growable: false),
      categoryFacets: _buildCategoryFacets(facetResponse.facets?['categoryId']),
    );
  }

  static SearchForHits _searchRequest({
    required String query,
    required int hitsPerPage,
    List<List<String>>? facetFilters,
    List<String>? numericFilters,
    List<String>? attributesToRetrieve,
  }) {
    return SearchForHits(
      indexName: _assetsIndexName,
      query: query,
      hitsPerPage: hitsPerPage,
      filters: 'isDeleted:false AND status:${Availability.available.label}',
      facets: const [
        'categoryId',
        'categoryName',
        'subcategoryId',
        'subcategoryName',
      ],
      facetFilters: facetFilters,
      numericFilters: numericFilters,
      maxValuesPerFacet: 20,
      attributesToRetrieve: attributesToRetrieve,
    );
  }

  static List<List<String>>? buildFacetFilters(
    List<String> categoryIds, {
    String? currencyCode,
  }) {
    final normalizedCategoryIds = categoryIds
        .map((categoryId) => categoryId.trim())
        .where((categoryId) => categoryId.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final normalizedCurrency = currencyCode?.trim();

    if (normalizedCategoryIds.isEmpty &&
        (normalizedCurrency == null || normalizedCurrency.isEmpty)) {
      return null;
    }

    return [
      normalizedCategoryIds
          .map((categoryId) => 'categoryId:$categoryId')
          .toList(growable: false),
      if (normalizedCurrency != null && normalizedCurrency.isNotEmpty)
        ['rates.currency:$normalizedCurrency'],
    ].where((group) => group.isNotEmpty).toList(growable: false);
  }

  static List<String>? buildNumericFilters(AssetSearchPriceRange? priceRange) {
    if (priceRange == null || !priceRange.hasBounds) return null;

    return [
      if (priceRange.minDailyRate != null)
        'rates.daily >= ${priceRange.minDailyRate}',
      if (priceRange.maxDailyRate != null)
        'rates.daily <= ${priceRange.maxDailyRate}',
    ];
  }

  static List<AssetSearchFacetOption> _buildCategoryFacets(
    Map<String, int>? facets,
  ) {
    if (facets == null || facets.isEmpty) return [];

    final entries = facets.entries
      .where((entry) => entry.key.trim().isNotEmpty)
      .toList(growable: false)..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });

    return entries
        .map(
          (entry) =>
              AssetSearchFacetOption(value: entry.key, count: entry.value),
        )
        .toList(growable: false);
  }

  static SearchClient _searchClient() {
    if (!isConfigured) {
      throw StateError('Algolia search is not configured.');
    }

    return _client ??= SearchClient(
      appId: _applicationId,
      apiKey: _searchApiKey,
    );
  }
}
