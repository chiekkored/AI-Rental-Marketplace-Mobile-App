import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lend/core/models/qr_raw.model.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/core/services/listing_share.service.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/pages/token_view/token_view.page.dart';
import 'package:lend/utilities/enums/token.enum.dart';
import 'package:lend/utilities/helpers/camera_album.helper.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';

class ScanQRController extends GetxController {
  static final instance = Get.find<ScanQRController>();

  final MobileScannerController scannerController = MobileScannerController();
  RxBool isPermissionGranted = false.obs;

  @override
  void onInit() {
    checkAndStart();

    super.onInit();
  }

  @override
  void onClose() {
    scannerController.dispose();
    isPermissionGranted.close();

    super.onClose();
  }

  Future<void> checkAndStart() async {
    final status = await LNDCamerAlbumHelper.checkCameraPermission();

    if (status) {
      isPermissionGranted.value = true;
      _startScanner();
    } else {
      isPermissionGranted.value = false;
    }
  }

  void _startScanner() {
    scannerController.start();
  }

  void onDetect(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final raw = barcodes.first.rawValue;
      if (raw != null && raw.isNotEmpty) {
        scannerController.stop();

        await _handleScannedValue(raw);
      }
    }
  }

  void uploadQR() async {
    try {
      final hasAccess = await LNDCamerAlbumHelper.checkGalleryPermission();
      if (hasAccess) {
        final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          LNDLoading.show();

          BarcodeCapture? data = await scannerController.analyzeImage(
            image.path,
            formats: [BarcodeFormat.qrCode],
          );
          if (data != null && data.raw != null) {
            final qrMap =
                json.decode(json.encode(data.raw)) as Map<String, dynamic>;
            final qrData = QrRaw.fromMap(qrMap);

            if ((qrData.data?.first.rawValue?.isEmpty ?? false) ||
                qrData.data?.first.rawValue == null) {
              LNDLoading.hide();
              throw 'Empty raw value';
            }
            final token = qrData.data?.first.rawValue ?? '';
            await _handleScannedValue(token);
          } else {
            LNDSnackbar.showError('Invalid QR');
          }
          LNDLoading.hide();
        }
      }
    } catch (e, st) {
      LNDLoading.hide();
      final error = LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError(error);
    }
  }

  Future<void> _handleScannedValue(String raw) async {
    final listingShareCode = _listingShareCodeFromRawValue(raw);
    if (listingShareCode != null) {
      await _openListingShareCode(listingShareCode);
      return;
    }

    final result = await LNDBookingService.verifyToken(token: raw);
    result.fold(
      ifLeft: (data) async {
        await _validToken(data, raw);
      },
      ifRight: (error) {
        throw error;
      },
    );
  }

  String? _listingShareCodeFromRawValue(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;

    if (uri.scheme == 'https' &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'l') {
      final code = uri.pathSegments.last.trim();
      return code.isEmpty ? null : code;
    }

    if (uri.scheme == 'lend' &&
        uri.host == 'listing' &&
        uri.pathSegments.length == 1) {
      final code = uri.pathSegments.first.trim();
      return code.isEmpty ? null : code;
    }

    return null;
  }

  Future<void> _openListingShareCode(String code) async {
    try {
      LNDLoading.show();
      final result = await LNDListingShareService.resolveListingShareLink(
        code: code,
        context: ListingShareResolveContext.qrScan,
      );
      LNDLoading.hide();

      if (result.assetId.isEmpty) {
        LNDSnackbar.showError('Listing unavailable.');
        return;
      }

      await LNDNavigate.toAssetPage(args: Asset(id: result.assetId));
    } catch (e, st) {
      LNDLoading.hide();
      LNDLogger.e('Error opening listing QR', error: e, stackTrace: st);
      final message =
          LNDListingShareService.isUnavailableError(e)
              ? 'Listing unavailable.'
              : 'Unable to open this listing.';
      LNDSnackbar.showError(message);
    }
  }

  Future<void> _validToken(dynamic result, String token) async {
    try {
      LNDLoading.show();

      final response = await LNDBookingService.getAssetBooking(
        assetId: result['data']['assetId'],
        bookingId: result['data']['bookingId'],
      );

      response.fold(
        ifLeft: (tokenBooking) async {
          TokenType tokenType =
              result['data']['action'] == 'handover'
                  ? TokenType.handOver
                  : TokenType.returning;
          LNDLoading.hide();
          LNDNavigate.toTokenViewPage(
            args: TokenViewArgs(
              booking: tokenBooking,
              tokenType: tokenType,
              token: token,
            ),
          );
        },
        ifRight: (error) {
          LNDLoading.hide();
          LNDSnackbar.showError(error);
          LNDLogger.e(error, stackTrace: StackTrace.current);
        },
      );
    } catch (e, st) {
      LNDLoading.hide();
      final error = LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError(error);
    }
  }
}
