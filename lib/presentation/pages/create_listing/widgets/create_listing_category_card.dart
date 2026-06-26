import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/core/models/category.model.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/category_icon.helper.dart';

class CreateListingCategoryCard extends StatelessWidget {
  final LNDCategory category;
  final bool showIcon;
  final bool selected;
  final VoidCallback onTap;

  const CreateListingCategoryCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? colors.primary : colors.outline),
          color: colors.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              if (showIcon) ...[
                FaIcon(
                  categoryIconFromKey(category.iconKey),
                  color: selected ? colors.primary : colors.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: LNDText.medium(
                  text: category.name,
                  color: selected ? colors.primary : colors.textPrimary,
                  fontSize: 13,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
