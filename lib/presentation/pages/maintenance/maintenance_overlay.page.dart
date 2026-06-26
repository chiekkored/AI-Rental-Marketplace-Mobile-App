import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/maintenance/maintenance.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';

class MaintenanceOverlay extends GetWidget<MaintenanceController> {
  final Widget child;

  const MaintenanceOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(() {
          if (!controller.isEnabled) return const SizedBox.shrink();
          return const _MaintenanceBlocker();
        }),
      ],
    );
  }
}

class _MaintenanceBlocker extends StatelessWidget {
  const _MaintenanceBlocker();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Material(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      color: colors.warningSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.construction_rounded,
                      color: colors.warning,
                      size: 36.0,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  LNDText.bold(
                    text: 'Lend is under maintenance',
                    color: colors.textPrimary,
                    fontSize: 24.0,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 10.0),
                  LNDText.regular(
                    text:
                        'We are making updates right now. Please try again later.',
                    color: colors.textSecondary,
                    fontSize: 15.0,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 18.0),
                  LNDText.regular(
                    text: 'For updates and support, visit the ',
                    color: colors.textMuted,
                    fontSize: 14.0,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    textParts: [
                      LNDText.semibold(
                        text: 'Help Center',
                        color: colors.primary,
                        fontSize: 14.0,
                        onTap: LNDLegalLinks.openHelpCenter,
                      ),
                      LNDText.regular(text: '.', color: colors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
