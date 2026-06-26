import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/amenity/amenity.controller.dart';
import 'package:lend/presentation/pages/asset/widgets/details/detail_formatters.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/amenity_icon.helper.dart';

class AssetDetailChipWrap extends StatelessWidget {
  const AssetDetailChipWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8.0, runSpacing: 8.0, children: children);
  }
}

class AssetDetailTextChip extends StatelessWidget {
  const AssetDetailTextChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            [
              if (icon != null)
                Icon(icon, size: 18.0, color: colors.textPrimary),
              if (icon != null) const SizedBox(width: 8.0),
              Flexible(
                child: LNDText.medium(
                  text: label,
                  fontSize: 13.0,
                  overflow: TextOverflow.visible,
                ),
              ),
            ].whereType<Widget>().toList(),
      ),
    );
  }
}

class AssetAmenityChip extends StatelessWidget {
  const AssetAmenityChip({super.key, required this.amenityId});

  final String amenityId;

  @override
  Widget build(BuildContext context) {
    final amenity =
        Get.isRegistered<AmenityController>()
            ? AmenityController.instance.findById(amenityId)
            : null;
    final icon = amenityIconFromKey(amenity?.iconKey);
    final label =
        amenity?.label.trim().isNotEmpty == true
            ? amenity!.label
            : readableDetailValue(amenityId);

    return AssetDetailTextChip(label: label, icon: icon.icon);
  }
}
