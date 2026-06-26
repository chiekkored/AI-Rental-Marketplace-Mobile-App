import 'package:gal/gal.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:permission_handler/permission_handler.dart';

class LNDCamerAlbumHelper {
  static Future<bool> checkGalleryPermission() async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (hasAccess) {
        return true;
      } else {
        final result = await Gal.requestAccess(toAlbum: true);
        if (result) {
          return true;
        } else {
          _showRequestPopup('Gallery Access Denied');
          return false;
        }
      }
    } on GalException catch (e) {
      LNDLogger.e(e.type.message, error: e, stackTrace: e.stackTrace);
      return false;
    }
  }

  static Future<bool> checkCameraPermission() async {
    try {
      // Check camera permission status
      final status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      } else {
        // Request permission
        final result = await Permission.camera.request();
        if (result.isGranted) {
          return true;
        } else if (result.isPermanentlyDenied) {
          _showRequestPopup('Camera access denied');
          return false;
        } else {
          return false;
        }
      }
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      return false;
    }
  }

  static void _showRequestPopup(String label) {
    LNDShow.alertDialog(
      title: 'Gallery Access Denied',
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
            'camera access manually.',
          );
        }
      },
    );
  }
}
