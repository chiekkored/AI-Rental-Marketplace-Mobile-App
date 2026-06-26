import 'package:flutter/material.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

class LNDAppTheme {
  const LNDAppTheme._();

  static ThemeData get light =>
      _buildTheme(brightness: Brightness.light, colors: LNDTheme.light);

  static ThemeData get dark =>
      _buildTheme(brightness: Brightness.dark, colors: LNDTheme.dark);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required LNDTheme colors,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.info,
      onSecondary: colors.textInverse,
      error: colors.danger,
      onError: colors.textInverse,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );
    final baseTextTheme = Typography.material2021().black.apply(
      fontFamily: 'Inter',
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[colors],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      splashFactory: NoSplash.splashFactory,
      fontFamily: 'Inter',
      primaryColor: colors.primary,
      disabledColor: colors.disabled,
      textTheme: baseTextTheme,
      iconTheme: IconThemeData(color: colors.textPrimary),
      primaryIconTheme: IconThemeData(color: colors.onPrimary),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primarySoft,
        circularTrackColor: colors.primarySoft,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: colors.surface,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        modalBackgroundColor: colors.surface,
        modalBarrierColor: Colors.black.withValues(alpha: isDark ? 0.70 : 0.35),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colors.textSecondary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: TextStyle(
          color: colors.textInverse,
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceMuted,
        hintStyle: TextStyle(color: colors.textMuted),
        labelStyle: TextStyle(color: colors.textSecondary),
        errorStyle: TextStyle(color: colors.danger),
        helperStyle: TextStyle(color: colors.textMuted),
        prefixIconColor: colors.textPrimary,
        suffixIconColor: colors.textPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.disabled,
          disabledForegroundColor: colors.textInverse,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.disabled,
          side: BorderSide(color: colors.outline),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          disabledForegroundColor: colors.disabled,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceMuted,
        selectedColor: colors.primary,
        disabledColor: colors.disabled,
        labelStyle: TextStyle(color: colors.textPrimary),
        secondaryLabelStyle: TextStyle(color: colors.onPrimary),
        side: BorderSide(color: colors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.disabled;
          if (states.contains(WidgetState.selected)) return colors.onPrimary;
          return colors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.outline;
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.unselected;
        }),
      ),
    );
  }
}
