import 'package:flutter/material.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class OwnerListingCard extends StatelessWidget {
  const OwnerListingCard({
    super.key,
    required this.availableCount,
    required this.hiddenCount,
    required this.onCreateListing,
    required this.onOpenListings,
    required this.underMaintenanceCount,
  });

  final int availableCount;
  final int hiddenCount;
  final VoidCallback onCreateListing;
  final VoidCallback onOpenListings;
  final int underMaintenanceCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onOpenListings,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sell_outlined, color: colors.textPrimary),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: LNDText.semibold(
                      text: 'Your listing',
                      color: colors.textPrimary,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.textPrimary),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _ListingCountColumn(
                      label: 'Available',
                      value: availableCount,
                      color: colors.info,
                    ),
                  ),
                  Expanded(
                    child: _ListingCountColumn(
                      label: 'Maintenance',
                      value: underMaintenanceCount,
                      color: colors.warning,
                    ),
                  ),
                  Expanded(
                    child: _ListingCountColumn(
                      label: 'Hidden',
                      value: hiddenCount,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              LNDButton.primary(
                text: '+ Create listing',
                enabled: true,
                hasPadding: false,
                onPressed: onCreateListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingCountColumn extends StatelessWidget {
  const _ListingCountColumn({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LNDText.bold(text: value.toString(), color: color, fontSize: 18.0),
        const SizedBox(height: 4.0),
        LNDText.regular(
          text: label,
          color: colors.textMuted,
          fontSize: 11.0,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
