import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

class LNDTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final InputDecoration Function(BuildContext context) decorationBuilder;
  final void Function(String)? onChanged;
  final bool autofocus;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int maxLength;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool? displayCommas;

  const LNDTextField._(
    this.controller,
    this.obscureText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.decorationBuilder,
    this.autofocus,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly,
    this.textCapitalization,
    this.maxLines,
    this.validator,
    this.maxLength,
    this.focusNode,
    this.displayCommas,
  );

  static InputDecoration inputDecoration({
    LNDTheme colors = LNDTheme.light,
    String? hintText,
    String? labelText,
    String? errorText,
    double? borderRadius,
    IconData? prefixIcon,
    Color? prefixIconColor,
    double? prefixIconSize,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? prefixText,
    TextStyle? prefixStyle,
    String? suffixText,
    IconData? suffixIcon,
    void Function()? onTapSuffix,
    Color? suffixIconColor,
    double? suffixIconSize,
    String? helperText,
    bool? required,
  }) {
    return _inputDecoration(
      colors: colors,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      borderRadius: borderRadius,
      prefixIcon: prefixIcon,
      prefixIconColor: prefixIconColor,
      prefixIconSize: prefixIconSize,
      prefixWidget: prefixWidget,
      suffixWidget: suffixWidget,
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      onTapSuffix: onTapSuffix,
      suffixIconColor: suffixIconColor,
      suffixIconSize: suffixIconSize,
      helperText: helperText,
      required: required,
    );
  }

  static InputDecoration _inputDecoration({
    required LNDTheme colors,
    String? hintText,
    String? labelText,
    String? errorText,
    double? borderRadius,
    IconData? prefixIcon,
    Color? prefixIconColor,
    double? prefixIconSize,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? prefixText,
    TextStyle? prefixStyle,
    String? suffixText,
    IconData? suffixIcon,
    void Function()? onTapSuffix,
    Color? suffixIconColor,
    double? suffixIconSize,
    String? helperText,
    bool? required,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: LNDText.mediumStyle.copyWith(color: colors.textMuted),
      label:
          labelText == null
              ? null
              : LNDText.medium(text: labelText, required: required ?? false),
      counterText: '',
      helper:
          helperText == null
              ? null
              : LNDText.regular(
                text: helperText,
                fontSize: 12.0,
                color: colors.textMuted,
                overflow: TextOverflow.visible,
              ),
      errorText: errorText,
      errorStyle: LNDText.mediumStyle.copyWith(
        color: colors.danger,
        overflow: TextOverflow.visible,
      ),
      fillColor: colors.surfaceMuted,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
        borderSide: BorderSide(color: colors.primary),
      ),
      prefixText: prefixText,
      prefixStyle:
          prefixStyle ??
          LNDText.mediumStyle.copyWith(
            color: colors.textPrimary,
            fontSize: 12.0,
          ),
      prefix: prefixWidget,
      prefixIcon:
          prefixIcon != null
              ? Padding(
                padding: const EdgeInsets.only(left: 26.0, right: 12.0),
                child: Icon(
                  prefixIcon,
                  color: prefixIconColor ?? colors.textPrimary,
                  size: prefixIconSize,
                ),
              )
              : null,
      suffixIconConstraints: const BoxConstraints(maxHeight: double.infinity),
      suffixText: suffixText,
      suffixStyle: LNDText.mediumStyle.copyWith(
        color: colors.textPrimary,
        fontSize: 12.0,
      ),
      suffix: suffixWidget,
      suffixIcon:
          suffixIcon != null
              ? Padding(
                padding: const EdgeInsets.only(right: 26.0, left: 12.0),
                child: LNDButton.icon(
                  icon: suffixIcon,
                  size: suffixIconSize ?? 16.0,
                  color: suffixIconColor ?? colors.textPrimary,
                  onPressed: () {
                    onTapSuffix?.call();
                  },
                ),
              )
              : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
      ),
    );
  }

  factory LNDTextField.textBox({
    required TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.multiline,
    TextInputAction textInputAction = TextInputAction.newline,
    double borderRadius = 32.0,
    IconData? prefixIcon,
    IconData? suffixIcon,
    double? prefixIconSize,
    double? suffixIconSize,
    Color? prefixIconColor,
    Color? suffixIconColor,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? prefixText,
    TextStyle? prefixStyle,
    String? suffixText,
    void Function()? onTapSuffix,
    void Function(String)? onChanged,
    bool autofocus = false,
    void Function(String)? onFieldSubmitted,
    VoidCallback? onTap,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? Function(String?)? validator,
    int maxLines = 3,
    int maxLength = 1000,
    String? helperText,
    bool? required,
    FocusNode? focusNode,
    bool? displayCommas = false,
  }) {
    return LNDTextField._(
      controller,
      false,
      keyboardType,
      textInputAction,
      onChanged,
      (context) => _inputDecoration(
        colors: context.lndTheme,
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        borderRadius: borderRadius,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        prefixIconSize: prefixIconSize,
        suffixWidget: suffixWidget,
        prefixWidget: prefixWidget,
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        onTapSuffix: onTapSuffix,
        suffixIconColor: suffixIconColor,
        suffixIconSize: suffixIconSize,
        helperText: helperText,
        required: required,
      ),
      autofocus,
      onFieldSubmitted,
      onTap,
      readOnly,
      textCapitalization,
      maxLines,
      validator,
      maxLength,
      focusNode,
      displayCommas,
    );
  }

  factory LNDTextField.regular({
    required TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    double borderRadius = 32.0,
    IconData? prefixIcon,
    IconData? suffixIcon,
    double? prefixIconSize,
    double? suffixIconSize,
    Color? prefixIconColor,
    Color? suffixIconColor,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? prefixText,
    TextStyle? prefixStyle,
    String? suffixText,
    void Function()? onTapSuffix,
    void Function(String)? onChanged,
    bool autofocus = false,
    void Function(String)? onFieldSubmitted,
    VoidCallback? onTap,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? Function(String?)? validator,
    int maxLines = 1,
    int maxLength = 100,
    String? helperText,
    bool? required,
    FocusNode? focusNode,
    bool? displayCommas = true,
  }) {
    return LNDTextField._(
      controller,
      obscureText,
      keyboardType,
      textInputAction,
      onChanged,
      (context) => _inputDecoration(
        colors: context.lndTheme,
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        borderRadius: borderRadius,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        prefixIconSize: prefixIconSize,
        prefixWidget: prefixWidget,
        suffixWidget: suffixWidget,
        prefixText: prefixText,
        prefixStyle:
            prefixStyle ?? LNDText.mediumStyle.copyWith(fontSize: 16.0),
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        onTapSuffix: onTapSuffix,
        suffixIconColor: suffixIconColor,
        suffixIconSize: suffixIconSize,
        helperText: helperText,
        required: required,
      ),
      autofocus,
      onFieldSubmitted,
      onTap,
      readOnly,
      textCapitalization,
      maxLines,
      validator,
      maxLength,
      focusNode,
      displayCommas,
    );
  }

  factory LNDTextField.money({
    required TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.number,
    TextInputAction textInputAction = TextInputAction.next,
    double borderRadius = 32.0,
    IconData? prefixIcon,
    IconData? suffixIcon,
    double? prefixIconSize,
    double? suffixIconSize,
    Color? prefixIconColor,
    Color? suffixIconColor,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? prefixText = 'PHP ',
    TextStyle? prefixStyle,
    String? suffixText,
    void Function()? onTapSuffix,
    void Function(String)? onChanged,
    bool autofocus = false,
    void Function(String)? onFieldSubmitted,
    VoidCallback? onTap,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? helperText,
    bool? required,
    int maxLength = 9,
    FocusNode? focusNode,
    bool? displayCommas = true,
  }) {
    return LNDTextField._(
      controller,
      obscureText,
      keyboardType,
      textInputAction,
      onChanged,
      (context) => _inputDecoration(
        colors: context.lndTheme,
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        borderRadius: borderRadius,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        prefixIconSize: prefixIconSize,
        prefixWidget: prefixWidget,
        suffixWidget: suffixWidget,
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        onTapSuffix: onTapSuffix,
        suffixIconColor: suffixIconColor,
        suffixIconSize: suffixIconSize,
        helperText: helperText,
        required: required,
      ),
      autofocus,
      onFieldSubmitted,
      onTap,
      readOnly,
      textCapitalization,
      maxLines,
      validator,
      maxLength,
      focusNode,
      displayCommas,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return TextFormField(
      style: LNDText.regularStyle.copyWith(
        color:
            readOnly && onTap == null ? colors.textMuted : colors.textPrimary,
      ),
      minLines: 1,
      maxLines: maxLines,
      maxLength: maxLength,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: decorationBuilder(context),
      autofocus: autofocus,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      canRequestFocus: !readOnly,
      validator: validator,
      inputFormatters: [
        if (maxLines == 1) FilteringTextInputFormatter.singleLineFormatter,
        if (keyboardType == TextInputType.number && (displayCommas ?? false))
          _NumberFormatter(),
      ],
    );
  }
}

class _NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only digits, no decimal point
    final String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If the new text is empty, return an empty value
    if (newText.isEmpty) {
      return const TextEditingValue();
    }

    // Remove leading zeros, but allow a single 0
    String sanitizedText = newText;
    if (sanitizedText.startsWith('0') && sanitizedText.length > 1) {
      sanitizedText = sanitizedText.replaceFirst(RegExp(r'^0+'), '');
      // If all digits were zeros, keep one zero
      if (sanitizedText.isEmpty) {
        sanitizedText = '0';
      }
    }

    // Limit to 9 digits
    String limitedText = sanitizedText;
    if (limitedText.length > 9) {
      limitedText = limitedText.substring(0, 9);
    }

    // Add commas to the number for formatting
    final formattedNumber = limitedText.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    return TextEditingValue(
      text: formattedNumber,
      selection: TextSelection.collapsed(offset: formattedNumber.length),
    );
  }
}
