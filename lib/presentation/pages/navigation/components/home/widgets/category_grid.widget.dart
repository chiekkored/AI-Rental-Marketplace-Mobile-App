import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/category_icon.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

class CategoryGrid extends GetView<HomeController> {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = context.lndTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LNDText.bold(text: 'Categories', fontSize: 16.0),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 148.0,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: controller.visibleCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (_, index) {
                final category = controller.visibleCategories[index];
                final colors = _CategoryCardColors.fromCategory(
                  index,
                  themeColors,
                );
                return GestureDetector(
                  onTap:
                      () => LNDNavigate.toCategoryListingsPage(
                        categoryId: category.id,
                        categoryName: category.name,
                      ),
                  child: SizedBox(
                    width: 128.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: colors.border),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 52.0,
                            width: 52.0,
                            decoration: BoxDecoration(
                              color: colors.iconBackground,
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Center(
                              child: FaIcon(
                                categoryIconFromKey(category.iconKey),
                                color: colors.foreground,
                                size: 24.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14.0),
                          LNDText.medium(
                            text: category.name,
                            fontSize: 12.0,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCardColors {
  const _CategoryCardColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color foreground;

  factory _CategoryCardColors.fromCategory(int index, LNDTheme themeColors) {
    switch (index % 6) {
      case 0:
        return _CategoryCardColors(
          background: themeColors.primarySoft,
          border: themeColors.primary.withValues(alpha: 0.24),
          iconBackground: themeColors.primary.withValues(alpha: 0.12),
          foreground: themeColors.primary,
        );
      case 1:
        return _CategoryCardColors(
          background: themeColors.infoSoft,
          border: themeColors.info.withValues(alpha: 0.24),
          iconBackground: themeColors.info.withValues(alpha: 0.12),
          foreground: themeColors.info,
        );
      case 2:
        return _CategoryCardColors(
          background: themeColors.successSoft,
          border: themeColors.success.withValues(alpha: 0.24),
          iconBackground: themeColors.success.withValues(alpha: 0.12),
          foreground: themeColors.success,
        );
      case 3:
        return _CategoryCardColors(
          background: themeColors.warningSoft,
          border: themeColors.warning.withValues(alpha: 0.24),
          iconBackground: themeColors.warning.withValues(alpha: 0.12),
          foreground: themeColors.warning,
        );
      case 4:
        return _CategoryCardColors(
          background: themeColors.dangerSoft,
          border: themeColors.danger.withValues(alpha: 0.24),
          iconBackground: themeColors.danger.withValues(alpha: 0.12),
          foreground: themeColors.danger,
        );
      default:
        return _CategoryCardColors(
          background: themeColors.surfaceMuted,
          border: themeColors.outline,
          iconBackground: themeColors.surface,
          foreground: themeColors.textPrimary,
        );
    }
  }
}
