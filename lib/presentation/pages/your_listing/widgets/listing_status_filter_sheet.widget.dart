import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/enums/availability.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ListingStatusFilterSheet extends StatelessWidget {
  const ListingStatusFilterSheet({super.key, required this.selected});

  final Availability selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LNDText.bold(text: 'Filter listings', fontSize: 18.0),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusTile(
                    icon: Icons.check_circle,
                    isSelected: selected == Availability.available,
                    status: Availability.available,
                  ),
                  Divider(height: 1.0, color: colors.outline),
                  _StatusTile(
                    icon: Icons.build,
                    isSelected: selected == Availability.underMaintenance,
                    status: Availability.underMaintenance,
                  ),
                  Divider(height: 1.0, color: colors.outline),
                  _StatusTile(
                    icon: Icons.visibility_off,
                    isSelected: selected == Availability.hidden,
                    status: Availability.hidden,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.isSelected,
    required this.status,
  });

  final IconData icon;
  final bool isSelected;
  final Availability status;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      leading: Icon(icon, color: _statusColor(colors, status)),
      onTap: () => Get.back(result: status),
      title: LNDText.medium(text: status.label),
      subtitle:
          status.subtitle.isEmpty
              ? null
              : LNDText.regular(
                text: status.subtitle,
                color: colors.textMuted,
                fontSize: 12.0,
                overflow: TextOverflow.visible,
              ),
      trailing:
          isSelected
              ? Icon(Icons.check_rounded, color: colors.primary)
              : const SizedBox(width: 24.0),
    );
  }
}

Color _statusColor(dynamic colors, Availability status) {
  return switch (status) {
    Availability.available => colors.info,
    Availability.underMaintenance => colors.warning,
    Availability.hidden => colors.textMuted,
  };
}
