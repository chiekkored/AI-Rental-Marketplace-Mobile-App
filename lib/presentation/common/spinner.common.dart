import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class LNDSpinner extends StatelessWidget {
  final Color? color;
  final double? size;
  const LNDSpinner({this.color, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final resolvedColor = color ?? colors.primary;
    return Platform.isIOS
        ? CupertinoActivityIndicator(color: resolvedColor)
        : SizedBox.square(
          dimension: size ?? 18.0,
          child: CircularProgressIndicator(color: resolvedColor),
        );
  }
}
