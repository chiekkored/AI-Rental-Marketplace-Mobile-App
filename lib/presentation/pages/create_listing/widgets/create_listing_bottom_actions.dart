import 'package:flutter/material.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingBottomActions extends StatelessWidget {
  final String primaryText;
  final VoidCallback primaryAction;
  final bool primaryEnabled;
  final bool primaryLoading;
  final String secondaryText;
  final VoidCallback secondaryAction;

  const CreateListingBottomActions({
    super.key,
    required this.primaryText,
    required this.primaryAction,
    this.primaryEnabled = true,
    this.primaryLoading = false,
    required this.secondaryText,
    required this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LNDButton.primary(
                text: primaryText,
                enabled: primaryEnabled,
                isLoading: primaryLoading,
                onPressed:
                    primaryEnabled && !primaryLoading ? primaryAction : null,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              const SizedBox(height: 8),
              LNDButton.outlined(
                text: secondaryText,
                enabled: true,
                onPressed: secondaryAction,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
