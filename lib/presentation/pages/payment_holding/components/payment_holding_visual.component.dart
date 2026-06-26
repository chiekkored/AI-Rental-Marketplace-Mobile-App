import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gal/gal.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PaymentHoldingVisual extends StatelessWidget {
  final bool isSuccess;
  final String? qrImageUrl;

  const PaymentHoldingVisual({
    required this.isSuccess,
    required this.qrImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final qr = qrImageUrl;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          isSuccess
              ? const _PaymentSuccessVisual(key: ValueKey('success'))
              : qr != null && qr.isNotEmpty
              ? _HoldingQrVisual(dataUri: qr, key: const ValueKey('qr'))
              : const _OrbitingPaymentVisual(key: ValueKey('orbit')),
    );
  }
}

class _PaymentSuccessVisual extends StatelessWidget {
  const _PaymentSuccessVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: 168.0,
      height: 168.0,
      decoration: BoxDecoration(
        color: colors.successSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, color: colors.success, size: 92.0),
    );
  }
}

class _OrbitingPaymentVisual extends StatefulWidget {
  const _OrbitingPaymentVisual({super.key});

  @override
  State<_OrbitingPaymentVisual> createState() => _OrbitingPaymentVisualState();
}

class _OrbitingPaymentVisualState extends State<_OrbitingPaymentVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SizedBox(
      width: 240.0,
      height: 240.0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _OrbitPath(
                color: colors.primary.withValues(alpha: 0.18),
                radius: 88.0,
              ),

              Container(
                width: 104.0,
                height: 104.0,
                padding: const EdgeInsets.all(22.0),
                child: SvgPicture.asset(
                  'assets/generated/lend_logo_orange.svg',
                ),
              ),

              _OrbitIcon(
                icon: FontAwesomeIcons.qrcode,
                angle: _controller.value * math.pi * 2,
              ),
              _OrbitIcon(
                icon: FontAwesomeIcons.creditCard,
                angle: _controller.value * math.pi * 2 + math.pi * 2 / 3,
              ),
              _OrbitIcon(
                icon: FontAwesomeIcons.wallet,
                angle: _controller.value * math.pi * 2 + math.pi * 4 / 3,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrbitPath extends StatelessWidget {
  final Color color;
  final double radius;

  const _OrbitPath({required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(240.0, 240.0),
      painter: _OrbitPathPainter(color: color, radius: radius),
    );
  }
}

class _OrbitPathPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _OrbitPathPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    const dotCount = 42;
    const dotRadius = 1.8;

    for (var i = 0; i < dotCount; i++) {
      final angle = math.pi * 2 * i / dotCount;
      final offset = Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawCircle(center + offset, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPathPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _OrbitIcon extends StatelessWidget {
  final IconData icon;
  final double angle;

  const _OrbitIcon({required this.icon, required this.angle});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    const radius = 88.0;
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: colors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Center(child: FaIcon(icon, size: 22.0, color: colors.primary)),
      ),
    );
  }
}

class _HoldingQrVisual extends StatelessWidget {
  final String dataUri;

  _HoldingQrVisual({required this.dataUri, super.key});

  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final bytes = _decodeQr(dataUri);
    if (bytes == null) return const _OrbitingPaymentVisual();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.memory(bytes, width: 230.0, height: 230.0),
          ),
        ),
        const SizedBox(height: 14.0),
        LNDButton.icon(
          icon: Icons.download_rounded,
          text: 'Save QR',
          onPressed: _saveQr,
          enabled: true,
          color: colors.textMuted,
          size: 18.0,
        ),
      ],
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
                'You have previously denied gallery access. Please go to Settings to enable it.',
            cancelText: 'Close',
            confirmText: 'Settings',
            onConfirm: () async {
              final canOpen = await openAppSettings();
              if (!canOpen) {
                LNDSnackbar.showWarning(
                  "Unable to open app settings. Open phone's settings and enable gallery access manually.",
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
