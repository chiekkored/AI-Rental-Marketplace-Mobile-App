import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SearchFieldComponent extends StatelessWidget {
  const SearchFieldComponent({
    super.key,
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.showClearButton = false,
    this.onTap,
    this.onClear,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final bool showClearButton;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final void Function(String)? onFieldSubmitted;

  static const heroTag = 'home-search-field';
  static const EdgeInsets outerPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );
  static const double borderRadius = 32.0;
  static const double iconSize = 16.0;
  static const double iconSpacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: LNDTextField.regular(
          controller: controller,
          focusNode: focusNode,
          prefixIcon: FontAwesomeIcons.magnifyingGlass,
          prefixIconColor: colors.textMuted,
          prefixIconSize: iconSize,
          suffixIcon: showClearButton ? Icons.close_rounded : null,
          suffixIconColor: colors.textMuted,
          suffixIconSize: 18.0,
          onTapSuffix: onClear,
          hintText: 'Search',
          readOnly: readOnly,
          onTap: onTap,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.none,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ),
    );
  }
}
