import 'package:flutter/material.dart';

@immutable
class LNDTheme extends ThemeExtension<LNDTheme> {
  final Color primary;
  final Color primaryPressed;
  final Color primarySoft;
  final Color onPrimary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color outline;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color disabled;
  final Color unselected;

  const LNDTheme({
    required this.primary,
    required this.primaryPressed,
    required this.primarySoft,
    required this.onPrimary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.outline,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.disabled,
    required this.unselected,
  });

  static const light = LNDTheme(
    primary: Color(0xFFFF6B00),
    primaryPressed: Color(0xFFCC5600),
    primarySoft: Color(0xFFFFF0E5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF7A7A7A),
    background: Color(0xFFF7F7F8),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF3F4F6),
    outline: Color(0xFFE4E4E7),
    divider: Color(0xFFECECEF),
    textPrimary: Color(0xFF18181B),
    textSecondary: Color(0xFF52525B),
    textMuted: Color(0xFF71717A),
    textInverse: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    successSoft: Color(0xFFEAF7EE),
    warning: Color(0xFFEAB308),
    warningSoft: Color(0xFFFEF9C3),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFDECEC),
    info: Color(0xFF2563EB),
    infoSoft: Color(0xFFEFF6FF),
    disabled: Color(0xFFA1A1AA),
    unselected: Color(0xFFC4C4CC),
  );

  static const dark = LNDTheme(
    primary: Color(0xFFFF6B00),
    primaryPressed: Color(0xFFFF8B33),
    primarySoft: Color(0xFF3A1D0B),
    onPrimary: Color(0xFF1B120B),
    secondary: Color(0xFF7A7A7A),
    background: Color(0xFF101012),
    surface: Color(0xFF18181B),
    surfaceMuted: Color(0xFF27272A),
    outline: Color(0xFF3F3F46),
    divider: Color(0xFF2F2F35),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFD4D4D8),
    textMuted: Color(0xFFA1A1AA),
    textInverse: Color(0xFF18181B),
    success: Color(0xFF22C55E),
    successSoft: Color(0xFF102A1A),
    warning: Color(0xFFFACC15),
    warningSoft: Color(0xFF312A07),
    danger: Color(0xFFEF4444),
    dangerSoft: Color(0xFF341212),
    info: Color(0xFF60A5FA),
    infoSoft: Color(0xFF10233D),
    disabled: Color(0xFF71717A),
    unselected: Color(0xFF52525B),
  );

  static LNDTheme of(BuildContext context) {
    return Theme.of(context).extension<LNDTheme>() ?? LNDTheme.light;
  }

  @override
  LNDTheme copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? primarySoft,
    Color? onPrimary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? outline,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? disabled,
    Color? unselected,
  }) {
    return LNDTheme(
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      disabled: disabled ?? this.disabled,
      unselected: unselected ?? this.unselected,
    );
  }

  @override
  LNDTheme lerp(ThemeExtension<LNDTheme>? other, double t) {
    if (other is! LNDTheme) return this;

    return LNDTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      unselected: Color.lerp(unselected, other.unselected, t)!,
    );
  }
}
