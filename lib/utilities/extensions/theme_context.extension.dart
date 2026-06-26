import 'package:flutter/material.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

extension LNDThemeContext on BuildContext {
  LNDTheme get lndTheme => LNDTheme.of(this);

  LNDTheme get lndColors => lndTheme;
}
