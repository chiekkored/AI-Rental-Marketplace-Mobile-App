class AssetSearchResult {
  const AssetSearchResult({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.imageUrl,
    required this.dailyRate,
    required this.currency,
    required this.status,
    required this.isDeleted,
    required this.averageRating,
    required this.reviewCount,
    this.ownerId,
  });

  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? imageUrl;
  final int? dailyRate;
  final String? currency;
  final String? status;
  final bool isDeleted;
  final double? averageRating;
  final int? reviewCount;
  final String? ownerId;

  factory AssetSearchResult.fromAlgoliaHit(Map<String, dynamic> hit) {
    final images = hit['images'];
    final rates = hit['rates'];

    return AssetSearchResult(
      id: _stringValue(hit['id']) ?? _stringValue(hit['objectID']) ?? '',
      title: _stringValue(hit['title']) ?? '',
      categoryId: _stringValue(hit['categoryId']) ?? '',
      categoryName: _stringValue(hit['categoryName']) ?? '',
      subcategoryId: _stringValue(hit['subcategoryId']),
      subcategoryName: _stringValue(hit['subcategoryName']),
      imageUrl:
          images is List && images.isNotEmpty
              ? _stringValue(images.first)
              : null,
      dailyRate:
          rates is Map<String, dynamic> ? _intValue(rates['daily']) : null,
      currency:
          rates is Map<String, dynamic>
              ? _stringValue(rates['currency'])
              : null,
      status: _stringValue(hit['status']),
      isDeleted: hit['isDeleted'] == true,
      averageRating: _doubleValue(hit['averageRating']),
      reviewCount: _intValue(hit['reviewCount']),
      ownerId: _stringValue(hit['ownerId']),
    );
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
