import 'package:flutter/material.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingDetailsReceiptContainer extends StatelessWidget {
  const BookingDetailsReceiptContainer({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(children: children),
    );
  }
}

class BookingDetailsReceiptRow extends StatelessWidget {
  const BookingDetailsReceiptRow({
    required this.label,
    required this.value,
    this.tooltip,
    this.infoTooltip,
    this.onInfoTap,
    this.isTotal = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isTotal;
  final String? tooltip;
  final String? infoTooltip;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final textColor = isTotal ? colors.textPrimary : colors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: LNDText.regular(
                    text: label,
                    color: textColor,
                    fontSize: 13.0,
                    overflow: TextOverflow.visible,
                  ),
                ),

                if (tooltip != null || onInfoTap != null) ...[
                  const SizedBox(width: 4),
                  if (onInfoTap != null)
                    LNDShow.tooltip(
                      message: infoTooltip ?? tooltip ?? label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onInfoTap,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    LNDShow.tooltip(
                      message: tooltip!,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Flexible(
            child:
                isTotal
                    ? LNDText.bold(text: value, fontSize: 13.0)
                    : LNDText.medium(
                      text: value,
                      fontSize: 13.0,
                      overflow: TextOverflow.visible,
                      isSelectable: true,
                    ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailsReceiptDivider extends StatelessWidget {
  const BookingDetailsReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(height: 1.0, color: colors.outline),
    );
  }
}
