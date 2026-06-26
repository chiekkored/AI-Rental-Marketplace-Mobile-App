import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class HomeEmptyState extends GetWidget<HomeController> {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final isPermissionDenied = controller.locationPermissionDenied;
    final hasLocationError = controller.browseLocationError.isNotEmpty;
    final message =
        isPermissionDenied
            ? 'Location permission is required to show listings around you.'
            : hasLocationError
            ? controller.browseLocationError
            : 'No listings found';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LNDText.regular(
              text: message,
              color: colors.textMuted,
              textAlign: TextAlign.center,
            ),
            if (isPermissionDenied || hasLocationError) ...[
              const SizedBox(height: 16.0),
              LNDButton.text(
                text: isPermissionDenied ? 'Open Settings' : 'Try Again',
                enabled: true,
                onPressed:
                    isPermissionDenied
                        ? controller.openLocationSettings
                        : controller.retryBrowseLocation,
                hasPadding: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
