import 'package:pluralize/pluralize.dart';

String readableDetailValue(String value) {
  return value
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) {
        if (part.length == 1) return part.toUpperCase();
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}

String? positiveIntLabel(int? value, String noun) {
  if (value == null || value <= 0) return null;
  return Pluralize().pluralize(noun, value, true);
}

String? minutesLabel(int? value, String noun) {
  if (value == null || value <= 0) return null;
  return '$noun: ${Pluralize().pluralize('minute', value, true)}';
}

String? nonEmptyText(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
