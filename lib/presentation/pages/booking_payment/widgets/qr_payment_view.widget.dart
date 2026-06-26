import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/booking_payment/widgets/payment_section.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:permission_handler/permission_handler.dart';

class QrPaymentView extends StatelessWidget {
  final String dataUri;

  QrPaymentView({required this.dataUri, super.key});

  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final bytes = _decodeQr(dataUri);
    if (bytes == null) return const SizedBox.shrink();

    return BookingPaymentSection(
      child: Column(
        children: [
          LNDText.bold(text: 'Scan to pay', fontSize: 16.0),
          const SizedBox(height: 12.0),
          RepaintBoundary(
            key: _qrKey,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.memory(bytes, width: 220.0, height: 220.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          LNDButton.icon(
            icon: Icons.download_rounded,
            text: 'Save QR',
            onPressed: _saveQr,
            enabled: true,
            color: colors.textMuted,
            size: 18.0,
          ),
        ],
      ),
    );
  }

  Future<void> _saveQr() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final result = await Gal.requestAccess();
        if (!result) {
          LNDShow.alertDialog(
            title: 'Gallery access denied',
            content:
                'You have previously denied gallery access. Please go to Settings '
                'to enable it.',
            cancelText: 'Close',
            confirmText: 'Settings',
            onConfirm: () async {
              final canOpen = await openAppSettings();

              if (!canOpen) {
                LNDSnackbar.showWarning(
                  "Unable to open app settings. Open phone's settings and enable "
                  'gallery access manually.',
                );
              }
            },
          );
          return;
        }
      }

      LNDLoading.show(text: 'Saving QR...');
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(
        pngBytes,
        album: 'Lend',
        name: 'Payment_QR_${DateTime.now().toIso8601String()}',
      );
      LNDSnackbar.showInfo('QR image downloaded');
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Failed to save QR image');
    } finally {
      LNDLoading.hide();
    }
  }

  Uint8List? _decodeQr(String uri) {
    final commaIndex = uri.indexOf(',');
    final raw = commaIndex >= 0 ? uri.substring(commaIndex + 1) : uri;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}
