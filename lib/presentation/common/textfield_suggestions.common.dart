import 'package:flutter/material.dart';
import 'package:lend/presentation/common/textfields.common.dart';

class LNDTextFieldWithSuggestions extends StatefulWidget {
  const LNDTextFieldWithSuggestions({
    required this.suggestions,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onSelected,
    this.labelText,
    this.required = false,
    this.validator,
    this.borderRadius = 12,
    super.key,
  });

  final List<String> suggestions;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onSelected;
  final String? labelText;
  final bool required;
  final String? Function(String?)? validator;
  final double borderRadius;

  @override
  State<LNDTextFieldWithSuggestions> createState() =>
      _LNDTextFieldWithSuggestionsState();
}

class _LNDTextFieldWithSuggestionsState
    extends State<LNDTextFieldWithSuggestions> {
  late final FocusNode _ownedFocusNode = FocusNode();

  FocusNode? get _autocompleteFocusNode =>
      widget.controller == null ? null : widget.focusNode ?? _ownedFocusNode;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _autocompleteFocusNode,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();

        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }

        return widget.suggestions.where(
          (item) => item.toLowerCase().contains(query),
        );
      },
      onSelected: (String selected) {
        widget.onSelected?.call(selected);
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return LNDTextField.regular(
          controller: textEditingController,
          focusNode: focusNode,
          hintText: widget.hintText,
          labelText: widget.labelText,
          required: widget.required,
          borderRadius: widget.borderRadius,
          validator:
              widget.validator ??
              (widget.required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                  : null),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  @override
  void dispose() {
    _ownedFocusNode.dispose();
    super.dispose();
  }
}
