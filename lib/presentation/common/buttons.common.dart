import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum _LNDButtonVariant { primary, secondary, shape, outlined, text, icon }

class LNDButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final Color? textColor;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final OutlinedBorder? shape;
  final bool hasPadding;
  final bool isButtonText;
  final bool isButtonIcon;
  final IconData? icon;
  final double iconSize;
  final ButtonStyle? style;
  final Widget? child;
  final bool isBold;
  final double? borderRadius;
  final EdgeInsets? padding;
  final int? maxLines;
  final _LNDButtonVariant _variant;

  const LNDButton._({
    required this.text,
    required this.onPressed,
    required this.enabled,
    required this.color,
    required _LNDButtonVariant variant,
    this.textColor,
    this.isLoading = false,
    this.shape,
    this.hasPadding = true,
    this.isButtonText = false,
    this.isButtonIcon = false,
    this.iconSize = 50.0,
    this.icon,
    this.style,
    this.child,
    this.isBold = false,
    this.borderRadius = 32.0,
    this.padding,
    this.maxLines,
  }) : _variant = variant;

  factory LNDButton.primary({
    required String text,
    required bool enabled,
    required VoidCallback? onPressed,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    EdgeInsets? padding,
    double? borderRadius,
    IconData? icon,
    double iconSize = 50.0,
    Color? textColor,
  }) {
    return LNDButton._(
      text: text,
      enabled: enabled,
      onPressed: onPressed,
      color: color,
      textColor: textColor,
      variant: _LNDButtonVariant.primary,
      isLoading: isLoading,
      hasPadding: hasPadding,
      padding: padding,
      borderRadius: borderRadius,
      icon: icon,
      iconSize: iconSize,
    );
  }

  factory LNDButton.secondary({
    required String text,
    required bool enabled,
    required VoidCallback? onPressed,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    EdgeInsets? padding,
    double? borderRadius,
    IconData? icon,
    double iconSize = 50.0,
    Color? textColor,
  }) {
    return LNDButton._(
      text: text,
      enabled: enabled,
      onPressed: onPressed,
      color: color,
      textColor: textColor,
      variant: _LNDButtonVariant.secondary,
      isLoading: isLoading,
      hasPadding: hasPadding,
      padding: padding,
      borderRadius: borderRadius,
      icon: icon,
      iconSize: iconSize,
    );
  }

  factory LNDButton.shape({
    required String text,
    required VoidCallback? onPressed,
    required bool enabled,
    required Color color,
    Color? textColor,
    bool isLoading = false,
    OutlinedBorder? shape,
    bool hasPadding = true,
  }) {
    return LNDButton._(
      text: text,
      enabled: enabled,
      onPressed: onPressed,
      color: color,
      isLoading: isLoading,
      textColor: textColor,
      shape: shape,
      hasPadding: hasPadding,
      variant: _LNDButtonVariant.shape,
    );
  }

  factory LNDButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    required bool enabled,
    Color? textColor,
    bool isLoading = false,
    ButtonStyle? style,
    bool hasPadding = true,
    EdgeInsets? padding,
  }) {
    return LNDButton._(
      text: text,
      enabled: enabled,
      onPressed: onPressed,
      color: Colors.transparent,
      isLoading: isLoading,
      textColor: textColor,
      style: style,
      hasPadding: hasPadding,
      padding: padding,
      variant: _LNDButtonVariant.outlined,
    );
  }

  factory LNDButton.text({
    required String text,
    required VoidCallback? onPressed,
    required bool enabled,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    double size = 14.0,
    bool isBold = false,
    int? maxLines,
  }) {
    return LNDButton._(
      text: text,
      enabled: enabled,
      onPressed: onPressed,
      color: color,
      isLoading: isLoading,
      hasPadding: hasPadding,
      isButtonText: true,
      iconSize: size,
      isBold: isBold,
      maxLines: maxLines,
      variant: _LNDButtonVariant.text,
    );
  }

  factory LNDButton.icon({
    required IconData icon,
    required VoidCallback? onPressed,
    String text = '',
    bool? enabled,
    Color? color,
    bool isLoading = false,
    double size = 50,
  }) {
    return LNDButton._(
      text: text,
      enabled: true,
      onPressed: onPressed,
      color: color,
      isLoading: isLoading,
      isButtonText: true,
      isButtonIcon: true,
      icon: icon,
      iconSize: size,
      variant: _LNDButtonVariant.icon,
    );
  }

  factory LNDButton.widget({
    required Widget child,
    required VoidCallback? onPressed,
    bool? enabled,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    double size = 50,
    double borderRadius = 32.0,
  }) {
    return LNDButton._(
      text: '',
      enabled: true,
      onPressed: onPressed,
      color: color,
      borderRadius: borderRadius,
      isLoading: isLoading,
      hasPadding: hasPadding,
      isButtonText: true,
      isButtonIcon: true,
      iconSize: size,
      variant: _LNDButtonVariant.icon,
      child: child,
    );
  }

  factory LNDButton.back({
    bool? enabled,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    bool closeOverlays = false,
    VoidCallback? onPressed,
    double size = 40,
  }) {
    return LNDButton._(
      text: '',
      enabled: enabled ?? true,
      onPressed: onPressed ?? () => Get.back(closeOverlays: closeOverlays),
      color: color,
      isLoading: isLoading,
      hasPadding: hasPadding,
      isButtonText: true,
      isButtonIcon: true,
      icon: Icons.chevron_left_rounded,
      iconSize: size,
      variant: _LNDButtonVariant.icon,
    );
  }

  factory LNDButton.close({
    bool? enabled,
    Color? color,
    bool isLoading = false,
    bool hasPadding = true,
    double size = 20,
    bool closeOverlays = false,
  }) {
    return LNDButton._(
      text: '',
      enabled: true,
      onPressed: () => Get.back(closeOverlays: closeOverlays),
      color: color,
      isLoading: isLoading,
      hasPadding: hasPadding,
      isButtonText: true,
      isButtonIcon: true,
      icon: Icons.close_rounded,
      iconSize: size,
      variant: _LNDButtonVariant.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final resolvedColor =
        color ??
        switch (_variant) {
          _LNDButtonVariant.primary => colors.primary,
          _LNDButtonVariant.secondary => colors.secondary,
          _LNDButtonVariant.shape => colors.primary,
          _LNDButtonVariant.outlined => Colors.transparent,
          _LNDButtonVariant.text => colors.primary,
          _LNDButtonVariant.icon => colors.textPrimary,
        };
    final resolvedTextColor =
        textColor ??
        switch (_variant) {
          _LNDButtonVariant.primary => Colors.white,
          _LNDButtonVariant.secondary => Colors.white,
          _LNDButtonVariant.outlined => colors.primary,
          _LNDButtonVariant.text => resolvedColor,
          _LNDButtonVariant.icon => resolvedColor,
          _ => colors.onPrimary,
        };
    final disabledColor = colors.disabled;
    Widget childContent =
        isLoading
            ? LNDSpinner(color: resolvedTextColor)
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: iconSize,
                    color: enabled ? resolvedTextColor : disabledColor,
                  ),
                  const SizedBox(width: 4.0),
                ],
                LNDText.bold(
                  text: text,
                  color: enabled ? resolvedTextColor : disabledColor,
                ),
              ],
            );

    final isFuncEnabled =
        enabled
            ? isLoading
                ? null
                : onPressed
            : null;

    if (isButtonText) {
      return CupertinoButton(
        onPressed: isFuncEnabled,
        minimumSize: Size.square(iconSize),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 32.0)),
        color: child != null ? resolvedColor : null,
        child:
            isLoading
                ? LNDSpinner(color: resolvedColor)
                : isButtonIcon
                ? child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: iconSize,
                          color: enabled ? resolvedColor : disabledColor,
                        ),
                        if (text.isNotEmpty) ...[
                          const SizedBox(width: 4.0),
                          LNDText.medium(
                            text: text,
                            color: enabled ? resolvedColor : disabledColor,
                            fontSize: iconSize,
                          ),
                        ],
                      ],
                    )
                : isBold
                ? LNDText.bold(
                  text: text,
                  color: enabled ? resolvedColor : disabledColor,
                  fontSize: iconSize,
                  maxLines: maxLines,
                )
                : LNDText.medium(
                  text: text,
                  color: enabled ? resolvedColor : disabledColor,
                  fontSize: iconSize,
                  maxLines: maxLines,
                ),
      );
    } else {
      return OutlinedButton(
        onPressed: isFuncEnabled,
        style:
            style ??
            OutlinedButton.styleFrom(
              padding: hasPadding ? padding : EdgeInsets.zero,
              side:
                  _variant == _LNDButtonVariant.outlined
                      ? BorderSide(color: colors.outline)
                      : BorderSide.none,
              foregroundColor: resolvedTextColor,
              disabledForegroundColor: disabledColor,
              backgroundColor: enabled ? resolvedColor : colors.surfaceMuted,
              shape:
                  shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 32.0),
                  ),
            ),
        child:
            hasPadding
                ? Padding(
                  padding:
                      padding ?? const EdgeInsets.symmetric(vertical: 18.0),
                  child: Center(child: childContent),
                )
                : Center(child: childContent),
      );
    }
  }
}
