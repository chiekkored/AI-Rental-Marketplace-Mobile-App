import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.medium(text: label, color: colors.textMuted, fontSize: 12.0),
          const SizedBox(height: 4.0),
          LNDText.regular(
            text: value.trim().isEmpty ? 'Not provided' : value,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
