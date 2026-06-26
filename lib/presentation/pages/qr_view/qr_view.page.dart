// ignore_for_file: deprecated_member_use
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/pages/chat/chat.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRViewPage extends StatelessWidget {
  static const routeName = '/qr-view';
  QRViewPage({super.key});

  final GlobalKey qrKey = GlobalKey();

  Future<void> saveQr() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (hasAccess) {
        LNDLoading.show();

        final boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        await Gal.putImageBytes(
          pngBytes,
          album: 'Lend',
          name: 'Receive_QR_${DateTime.now().toIso8601String()}',
        );
        LNDSnackbar.showInfo('QR image downloaded');
      } else {
        final result = await Gal.requestAccess();
        if (!result) {
          LNDShow.alertDialog(
            title: 'Gallery access denied',
            content:
                'You have previously denied camera access. Please go to Settings '
                'to enable it.',
            cancelText: 'Close',
            confirmText: 'Settings',
            onConfirm: () async {
              final canOpen = await openAppSettings();

              if (!canOpen) {
                LNDSnackbar.showWarning(
                  "Unable to open app settings. Open phone's settings and enable "
                  'camera access manually.',
                );
              }
            },
          );
        } else {
          saveQr();
        }
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), stackTrace: st);
      LNDSnackbar.showError('Failed to save QR image');
    } finally {
      LNDLoading.hide();
    }
  }

  Future<void> debugBypassQr(String token) async {
    try {
      LNDLoading.show();

      final result = await LNDBookingService.markBooking(
        token: token,
        debugBypass: true,
      );

      result.fold(
        ifLeft: (_) {
          NowController.instance.refreshNow();
          LNDLoading.hide();
          LNDSnackbar.showSuccess('Debug QR transaction bypassed.');
          Get.until((route) {
            return route.settings.name == ChatPage.routeName || route.isFirst;
          });
        },
        ifRight: (error) {
          LNDLoading.hide();
          LNDSnackbar.showError(error);
        },
      );
    } catch (e, st) {
      LNDLoading.hide();
      final error = LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrToken = Get.arguments as String;
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        leading: LNDButton.back(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: RepaintBoundary(
              key: qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: QrImageView(
                  data: qrToken,
                  version: QrVersions.auto,
                  size: Get.width / 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (kDebugMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LNDButton.secondary(
                icon: Icons.bug_report_rounded,
                iconSize: 18.0,
                text: 'Bypass QR',
                onPressed: () => debugBypassQr(qrToken),
                enabled: true,
                color: colors.warning,
              ),
            ),
            const SizedBox(height: 12),
          ],
          LNDButton.icon(
            icon: Icons.download_rounded,
            text: 'Save QR',
            onPressed: saveQr,
            enabled: true,
            color: colors.textMuted,
            size: 18.0,
          ),
        ],
      ),
    );
  }
}
