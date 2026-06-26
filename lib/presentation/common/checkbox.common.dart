import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class LNDCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget title;
  final EdgeInsetsGeometry contentPadding;
  final Color? activeColor;
  final bool enabled;

  const LNDCheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.contentPadding = EdgeInsets.zero,
    this.activeColor,
    this.enabled = true,
  });

  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final resolvedActiveColor = activeColor ?? colors.primary;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Padding(
        padding: contentPadding,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isEnabled ? () => onChanged?.call(!value) : null,
          child: Row(
            children: [
              CupertinoCheckbox(
                value: value,
                onChanged: _isEnabled ? onChanged : null,
                activeColor: resolvedActiveColor,
              ),
              const SizedBox(width: 8),
              Expanded(child: title),
            ],
          ),
        ),
      );
    }

    return CheckboxListTile(
      value: value,
      onChanged: _isEnabled ? onChanged : null,
      contentPadding: contentPadding,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: resolvedActiveColor,
      title: title,
    );
  }
}
