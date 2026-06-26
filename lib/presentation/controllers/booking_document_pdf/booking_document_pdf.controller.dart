import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:lend/core/services/booking.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:path_provider/path_provider.dart';

class BookingDocumentPdfPageArgs {
  const BookingDocumentPdfPageArgs({
    required this.bookingId,
    required this.documentType,
    required this.title,
  });

  final String bookingId;
  final LNDBookingDocumentType documentType;
  final String title;
}

class BookingDocumentPdfController extends GetxController {
  final BookingDocumentPdfPageArgs args =
      Get.arguments as BookingDocumentPdfPageArgs;

  final RxBool isLoading = true.obs;
  final RxnString localPath = RxnString();
  final RxnString errorMessage = RxnString();

  String get title => args.title;

  @override
  void onInit() {
    super.onInit();
    loadDocument();
  }

  Future<void> loadDocument() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await LNDBookingService.getBookingDocument(
        bookingId: args.bookingId,
        bookingDocumentType: args.documentType,
      );

      final link = result.fold(
        ifLeft: (link) => link,
        ifRight: (error) => throw error,
      );

      if (link.contentBase64.trim().isEmpty) {
        throw 'Document content is unavailable.';
      }

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/${args.documentType.value}-${args.bookingId}.pdf',
      );
      await file.writeAsBytes(base64Decode(link.contentBase64));
      localPath.value = file.path;
    } catch (e, st) {
      LNDLogger.e('Unable to load booking document', error: e, stackTrace: st);
      const message = 'Unable to load booking document. Please try again later.';
      errorMessage.value = message;
      LNDSnackbar.showError(message);
    } finally {
      isLoading.value = false;
    }
  }
}
