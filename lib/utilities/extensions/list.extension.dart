extension NullableStringListExtension on List<String>? {
  String? get firstImageUrl {
    final values = this;
    if (values == null || values.isEmpty) return null;
    return values.first;
  }
}
