String listingDetailString(dynamic value, {String fallback = ''}) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? fallback : text;
}

int? listingDetailInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().replaceAll(',', '').trim() ?? '');
}

List<String> listingDetailStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}
