import 'package:flutter/material.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_bottom_actions.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_step_header.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingStepScaffold extends StatelessWidget {
  final int stepIndex;
  final String title;
  final String description;
  final Widget child;
  final String primaryText;
  final VoidCallback primaryAction;
  final bool primaryEnabled;
  final bool primaryLoading;
  final String secondaryText;
  final VoidCallback secondaryAction;
  final bool showDummyButton;
  final VoidCallback? dummyAction;

  const CreateListingStepScaffold({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.description,
    required this.child,
    required this.primaryText,
    required this.primaryAction,
    this.primaryEnabled = true,
    this.primaryLoading = false,
    required this.secondaryText,
    required this.secondaryAction,
    this.showDummyButton = false,
    this.dummyAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CreateListingStepHeader(stepIndex: stepIndex),
                    const SizedBox(height: 28),
                    LNDText.bold(
                      text: title,
                      fontSize: 28,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 8),
                    LNDText.regular(
                      text: description,
                      color: colors.textMuted,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 24),
                    child,
                    if (showDummyButton && dummyAction != null) ...[
                      const SizedBox(height: 16),
                      LNDButton.secondary(
                        text: 'Post dummy data',
                        enabled: true,
                        onPressed: dummyAction,
                        borderRadius: 12,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            CreateListingBottomActions(
              primaryText: primaryText,
              primaryAction: primaryAction,
              primaryEnabled: primaryEnabled,
              primaryLoading: primaryLoading,
              secondaryText: secondaryText,
              secondaryAction: secondaryAction,
            ),
          ],
        ),
      ),
    );
  }
}
