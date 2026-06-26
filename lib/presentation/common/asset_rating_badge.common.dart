import 'package:flutter/material.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';

class AssetRatingBadge extends StatelessWidget {
  const AssetRatingBadge({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    this.compact = false,
  });

  final double? averageRating;
  final int? reviewCount;
  final bool compact;

  static bool shouldShow({
    required double? averageRating,
    required int? reviewCount,
  }) {
    return averageRating != null && (reviewCount ?? 0) > 0;
  }

  static String ratingLabel(double value) => LNDUtils.ratingLabel(value);

  @override
  Widget build(BuildContext context) {
    if (!shouldShow(averageRating: averageRating, reviewCount: reviewCount)) {
      return const SizedBox.shrink();
    }

    final colors = context.lndTheme;
    final height = compact ? 20.0 : 24.0;
    final iconSize = compact ? 12.0 : 14.0;
    final fontSize = compact ? 10.0 : 11.0;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6.0 : 7.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: colors.warning, size: iconSize),
          const SizedBox(width: 2.0),
          Text(
            ratingLabel(averageRating!),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
