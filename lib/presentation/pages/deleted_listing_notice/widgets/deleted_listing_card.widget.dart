import 'package:flutter/material.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/money.helper.dart';

class DeletedListingCard extends StatelessWidget {
  final String? imageUrl;
  final Asset listing;

  const DeletedListingCard({
    super.key,
    required this.imageUrl,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final dailyRate = listing.rates?.daily;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDImage.square(imageUrl: imageUrl, size: 88.0, borderRadius: 8.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.bold(
                    text: _textOrDefault(listing.title, 'Untitled listing'),
                    color: colors.textPrimary,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4.0),
                  LNDText.regular(
                    text: _textOrDefault(listing.categoryName, 'No category'),
                    color: colors.textMuted,
                    fontSize: 13.0,
                  ),
                  if (dailyRate != null) ...[
                    const SizedBox(height: 8.0),
                    LNDText.semibold(
                      text:
                          '${LNDMoney.formatRate(dailyRate, listing.rates)} / day',
                      color: colors.primary,
                      fontSize: 14.0,
                    ),
                  ],
                  if (listing.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8.0),
                    LNDText.regular(
                      text: listing.description!.trim(),
                      color: colors.textMuted,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _textOrDefault(String? value, String fallback) {
    final text = value?.trim();
    return text?.isNotEmpty == true ? text! : fallback;
  }
}
