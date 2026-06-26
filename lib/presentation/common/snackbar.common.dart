import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum _LNDSnackbarTone { info, success, error, warning }

class LNDSnackbar {
  static void showInfo(
    String message, {
    String title = '',
    bool showButton = false,
    String buttonText = '',
    VoidCallback? buttonOnPressed,
  }) {
    _showSnackbar(
      title,
      message,
      _LNDSnackbarTone.info,
      showButton,
      buttonText,
      buttonOnPressed,
    );
  }

  static void showSuccess(
    String message, {
    String title = '',
    bool showButton = false,
    String buttonText = '',
    VoidCallback? buttonOnPressed,
  }) {
    _showSnackbar(
      title,
      message,
      _LNDSnackbarTone.success,
      showButton,
      buttonText,
      buttonOnPressed,
    );
  }

  static void showError(
    String message, {
    String title = '',
    bool showButton = false,
    String buttonText = '',
    VoidCallback? buttonOnPressed,
  }) {
    _showSnackbar(
      title,
      message,
      _LNDSnackbarTone.error,
      showButton,
      buttonText,
      buttonOnPressed,
    );
  }

  static void showWarning(
    String message, {
    String title = '',
    bool showButton = false,
    String buttonText = '',
    VoidCallback? buttonOnPressed,
  }) {
    _showSnackbar(
      title,
      message,
      _LNDSnackbarTone.warning,
      showButton,
      buttonText,
      buttonOnPressed,
    );
  }

  static void _showSnackbar(
    String title,
    String message,
    _LNDSnackbarTone tone,
    bool showButton,
    String buttonText,
    VoidCallback? buttonOnPressed,
  ) async {
    final context = Get.context!;
    final colors = context.lndTheme;
    final color = switch (tone) {
      _LNDSnackbarTone.info => colors.surface,
      _LNDSnackbarTone.success => colors.success,
      _LNDSnackbarTone.error => colors.danger,
      _LNDSnackbarTone.warning => colors.warning,
    };
    final textColor =
        tone == _LNDSnackbarTone.info ? colors.textPrimary : colors.textInverse;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin:
              Platform.isAndroid
                  ? const EdgeInsets.all(8.0)
                  : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          dismissDirection: DismissDirection.vertical,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      LNDText.bold(
                        text: title,
                        color: textColor,
                        fontSize: 18.0,
                      ),
                    LNDText.regular(
                      text: message,
                      color: textColor,
                      overflow: TextOverflow.clip,
                      fontSize: 12.0,
                    ),
                  ],
                ),
              ),
              if (showButton)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: LNDButton.text(
                    text: buttonText,
                    onPressed: () {
                      buttonOnPressed?.call();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    enabled: true,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      );
  }
}
