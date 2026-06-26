import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PaymentMethodAccordion extends StatelessWidget {
  final String title;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  const PaymentMethodAccordion({
    required this.title,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          iconColor: colors.textPrimary,
          collapsedIconColor: colors.textMuted,
          title: LNDText.bold(text: title, fontSize: 16.0),
          children: [child],
        ),
      ),
    );
  }
}
