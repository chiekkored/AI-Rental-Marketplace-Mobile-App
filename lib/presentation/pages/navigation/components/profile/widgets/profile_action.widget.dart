import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ProfileAction extends StatelessWidget {
  const ProfileAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.svg,
    this.showTrailing = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool showTrailing;
  final SvgPicture? svg;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.lndTheme.textPrimary;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 25.0,
        height: 25.0,
        child: svg ?? Icon(icon, color: resolvedColor),
      ),
      onTap: onTap,
      splashColor: Colors.transparent,
      title: LNDText.regular(text: label, color: resolvedColor),
      trailing:
          showTrailing
              ? Icon(Icons.chevron_right_rounded, color: resolvedColor)
              : null,
    );
  }
}
