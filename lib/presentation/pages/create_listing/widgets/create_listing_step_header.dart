import 'package:flutter/material.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingStepHeader extends StatelessWidget {
  final int stepIndex;

  const CreateListingStepHeader({super.key, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    final totalSteps = CreateListingController.instance.totalSteps;
    final progress = (stepIndex + 1) / totalSteps;
    final colors = context.lndTheme;
    return Column(
      children: [
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: LNDText.medium(
        //     text:
        //         'Step ${stepIndex + 1} of ${CreateListingController.totalSteps}',
        //     color: colors.textMuted,
        //     fontSize: 12,
        //   ),
        // ),
        // const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: progress,
            color: colors.primary,
            backgroundColor: colors.outline,
          ),
        ),
      ],
    );
  }
}
